# frozen_string_literal: true

module Projects
  class PropagateServiceTemplate
    BATCH_SIZE = 100

    def self.propagate(template)
      new(template).propagate
    end

    def initialize(template)
      @template = template
    end

    def propagate
      return unless template.active?

      propagate_projects_with_template
    end

    private

    attr_reader :template

    def propagate_projects_with_template
      loop do
        batch = Project.uncached { project_ids_batch }

        bulk_create_from_template(batch) unless batch.empty?

        break if batch.size < BATCH_SIZE
      end
    end

    def bulk_create_from_template(batch)
      service_list = batch.map do |project_id|
        service_hash.values << project_id
      end

      Project.transaction do
        results = bulk_insert('services', service_hash.keys << 'project_id', service_list)

        if data_fields_present?
          data_list = results.rows.flatten.map do |service_id|
            data_hash.values << service_id
          end

          bulk_insert(template.data_fields.class.table_name, data_hash.keys << 'service_id', data_list)
        end

        run_callbacks(batch)
      end
    end

    def project_ids_batch
      Project.connection.select_values(
        <<-SQL
          SELECT id
          FROM projects
          WHERE NOT EXISTS (
            SELECT true
            FROM services
            WHERE services.project_id = projects.id
            AND services.type = '#{template.type}'
          )
          AND projects.pending_delete = false
          AND projects.archived = false
          LIMIT #{BATCH_SIZE}
        SQL
      )
    end

    def bulk_insert(table, columns, values_array)
      ActiveRecord::Base.connection.exec_query(
        <<~SQL
          INSERT INTO #{table} (#{columns.join(', ')})
          VALUES #{values_array.map { |tuple| "(#{tuple.join(', ')})" }.join(', ')}
          RETURNING id
        SQL
      )
    end

    def service_hash
      @service_hash ||=
        begin
          template_hash = template.as_json(methods: :type).except('id', 'template', 'project_id')

          template_hash.each_with_object({}) do |(key, value), service_hash|
            value = value.is_a?(Hash) ? value.to_json : value

            service_hash[ActiveRecord::Base.connection.quote_column_name(key)] =
              ActiveRecord::Base.connection.quote(value)
          end
        end
    end

    def data_hash
      @data_hash ||= begin
        template_data_hash = template.data_fields.as_json(only: template.data_fields.class.column_names).except('id', 'service_id')

        template_data_hash.each_with_object({}) do |(key, value), template_data_hash|
          template_data_hash[ActiveRecord::Base.connection.quote_column_name(key)] =
            ActiveRecord::Base.connection.quote(value)
        end
      end
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
      template.issue_tracker? && !template.default
    end

    def active_external_wiki?
      template.type == 'ExternalWikiService'
    end

    def data_fields_present?
      template.data_fields_present?
    end
  end
end
