# frozen_string_literal: true

module Admin
  class PropagateIntegrationService
    BATCH_SIZE = 100

    delegate :data_fields_present?, to: :integration

    def self.propagate(integration:, update_only_inherited:)
      new(integration, update_only_inherited).propagate
    end

    def initialize(integration, update_only_inherited)
      @integration = integration
      @update_only_inherited = update_only_inherited
    end

    def propagate
      if update_only_inherited
        update_integration_for_inherited_projects
      else
        update_integration_for_all_projects
      end

      create_integration_for_projects_without_integration
    end

    private

    attr_reader :integration, :update_only_inherited

    # rubocop: disable Cop/InBatches
    # rubocop: disable CodeReuse/ActiveRecord
    def update_integration_for_inherited_projects
      Service.where(type: integration.type, inherit_from_id: integration.id).in_batches(of: BATCH_SIZE) do |batch|
        bulk_update_from_integration(batch)
      end
    end

    def update_integration_for_all_projects
      Service.where(type: integration.type).in_batches(of: BATCH_SIZE) do |batch|
        bulk_update_from_integration(batch)
      end
    end
    # rubocop: enable Cop/InBatches
    # rubocop: enable CodeReuse/ActiveRecord

    # rubocop: disable CodeReuse/ActiveRecord
    def bulk_update_from_integration(batch)
      # Retrieving the IDs instantiates the ActiveRecord relation (batch)
      # into concrete models, otherwise update_all will clear the relation.
      # https://stackoverflow.com/q/34811646/462015
      batch_ids = batch.pluck(:id)

      Service.transaction do
        batch.update_all(service_hash)

        if data_fields_present?
          integration.data_fields.class.where(service_id: batch_ids).update_all(data_hash)
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def create_integration_for_projects_without_integration
      loop do
        batch = Project.uncached { project_ids_without_integration }

        bulk_create_from_integration(batch) unless batch.empty?

        break if batch.size < BATCH_SIZE
      end
    end

    def bulk_create_from_integration(batch)
      service_list = batch.map do |project_id|
        service_hash.values << project_id << integration.id
      end

      Project.transaction do
        results = bulk_insert(Service, service_hash.keys << 'project_id' << 'inherit_from_id', service_list)

        if data_fields_present?
          data_list = results.map { |row| data_hash.values << row['id'] }

          bulk_insert(integration.data_fields.class, data_hash.keys << 'service_id', data_list)
        end

        run_callbacks(batch)
      end
    end

    def bulk_insert(klass, columns, values_array)
      items_to_insert = values_array.map { |array| Hash[columns.zip(array)] }

      klass.insert_all(items_to_insert, returning: [:id])
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def run_callbacks(batch)
      if active_external_issue_tracker?
        Project.where(id: batch).update_all(has_external_issue_tracker: true)
      end

      if active_external_wiki?
        Project.where(id: batch).update_all(has_external_wiki: true)
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def active_external_issue_tracker?
      integration.issue_tracker? && !integration.default
    end

    def active_external_wiki?
      integration.type == 'ExternalWikiService'
    end

    def project_ids_without_integration
      Project.connection.select_values(
        <<-SQL
          SELECT id
          FROM projects
          WHERE NOT EXISTS (
            SELECT true
            FROM services
            WHERE services.project_id = projects.id
            AND services.type = #{ActiveRecord::Base.connection.quote(integration.type)}
          )
          AND projects.pending_delete = false
          AND projects.archived = false
          LIMIT #{BATCH_SIZE}
        SQL
      )
    end

    def service_hash
      @service_hash ||= integration
        .as_json(methods: :type, except: %w[id instance project_id])
        .tap { |json| json['inherit_from_id'] = integration.id }
    end

    def data_hash
      @data_hash ||= integration.data_fields.as_json(only: integration.data_fields.class.column_names).except('id', 'service_id')
    end
  end
end
