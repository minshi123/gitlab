# frozen_string_literal: true

module Gitlab
  module ImportExport
    class RelationTreeRestorer
      # Relations which cannot be saved at project level (and have a group assigned)
      GROUP_MODELS = [GroupLabel, Milestone, Epic].freeze

      attr_reader :user
      attr_reader :shared
      attr_reader :importable
      attr_reader :relation_reader

      def initialize(user:, shared:, importable:, relation_reader:, members_mapper:, object_builder:, relation_factory:, reader:)
        @user = user
        @shared = shared
        @importable = importable
        @relation_reader = relation_reader
        @members_mapper = members_mapper
        @object_builder = object_builder
        @relation_factory = relation_factory
        @reader = reader
      end

      def restore
        ActiveRecord::Base.uncached do
          ActiveRecord::Base.no_touching do
            update_params!

            bulk_inserts_enabled = @importable.class == ::Project &&
              Feature.enabled?(:import_bulk_inserts, @importable.group)
            BulkInsertableAssociations.with_bulk_insert(enabled: bulk_inserts_enabled) do
              fix_ci_pipelines_not_sorted_on_legacy_project_json!
              create_relations!
            end
          end
        end

        # ensure that we have latest version of the restore
        @importable.reload # rubocop:disable Cop/ActiveRecordAssociationReload

        true
      rescue => e
        @shared.error(e)
        false
      end

      private

      # Loops through the tree of models defined in import_export.yml and
      # finds them in the imported JSON so they can be instantiated and saved
      # in the DB. The structure and relationships between models are guessed from
      # the configuration yaml file too.
      # Finally, it updates each attribute in the newly imported project/group.
      def create_relations!
        relations.each(&method(:process_relation!))
      end

      def process_relation!(relation_key, relation_definition)
        @relation_reader.consume_relation(relation_key) do |data_hash, relation_index|
          process_relation_item!(relation_key, relation_definition, relation_index, data_hash)
        end
      end

      def process_relation_item!(relation_key, relation_definition, relation_index, data_hash)
        relation_object = build_relation(relation_key, relation_definition, data_hash)
        return unless relation_object
        return if importable_class == ::Project && group_model?(relation_object)

        relation_object.assign_attributes(importable_class_sym => @importable)

        import_failure_service.with_retry(action: 'relation_object.save!', relation_key: relation_key, relation_index: relation_index) do
          relation_object.save!
        end
      rescue => e
        import_failure_service.log_import_failure(
          source: 'process_relation_item!',
          relation_key: relation_key,
          relation_index: relation_index,
          exception: e)
      end

      def import_failure_service
        @import_failure_service ||= ImportFailureService.new(@importable)
      end

      def relations
        @relations ||=
          @reader
            .attributes_finder
            .find_relations_tree(importable_class_sym)
            .deep_stringify_keys
      end

      def update_params!
        params = @relation_reader.root_attributes(relations.keys)
        params = params.merge(present_override_params)

        # Cleaning all imported and overridden params
        params = Gitlab::ImportExport::AttributeCleaner.clean(
          relation_hash:  params,
          relation_class: importable_class,
          excluded_keys:  excluded_keys_for_relation(importable_class_sym))

        @importable.assign_attributes(params)
        @importable.drop_visibility_level! if importable_class == ::Project

        Gitlab::Timeless.timeless(@importable) do
          @importable.save!
        end
      end

      def present_override_params
        # we filter out the empty strings from the overrides
        # keeping the default values configured
        override_params&.transform_values do |value|
          value.is_a?(String) ? value.presence : value
        end&.compact
      end

      def override_params
        @importable_override_params ||= importable_override_params
      end

      def importable_override_params
        if @importable.respond_to?(:import_data)
          @importable.import_data&.data&.fetch('override_params', nil) || {}
        else
          {}
        end
      end

      def build_relations(relation_key, relation_definition, data_hashes)
        data_hashes.map do |data_hash|
          build_relation(relation_key, relation_definition, data_hash)
        end.compact
      end

      def build_relation(relation_key, relation_definition, data_hash)
        # TODO: This is hack to not create relation for the author
        # Rather make `RelationFactory#set_note_author` to take care of that
        return data_hash if relation_key == 'author' || already_restored?(data_hash)

        # create relation objects recursively for all sub-objects
        relation_definition.each do |sub_relation_key, sub_relation_definition|
          transform_sub_relations!(data_hash, sub_relation_key, sub_relation_definition)
        end

        @relation_factory.create(relation_factory_params(relation_key, data_hash))
      end

      # Since we update the data hash in place as we restore relation items,
      # and since we also de-duplicate items, we might encounter items that
      # have already been restored in a previous iteration.
      def already_restored?(relation_item)
        !relation_item.is_a?(Hash)
      end

      def transform_sub_relations!(data_hash, sub_relation_key, sub_relation_definition)
        sub_data_hash = data_hash[sub_relation_key]
        return unless sub_data_hash

        # if object is a hash we can create simple object
        # as it means that this is 1-to-1 vs 1-to-many
        current_item =
          if sub_data_hash.is_a?(Array)
            build_relations(
              sub_relation_key,
              sub_relation_definition,
              sub_data_hash).presence
          else
            build_relation(
              sub_relation_key,
              sub_relation_definition,
              sub_data_hash)
          end

        if current_item
          data_hash[sub_relation_key] = current_item
        else
          data_hash.delete(sub_relation_key)
        end
      end

      def group_model?(relation_object)
        GROUP_MODELS.include?(relation_object.class) && relation_object.group_id
      end

      def excluded_keys_for_relation(relation)
        @reader.attributes_finder.find_excluded_keys(relation)
      end

      def importable_class
        @importable.class
      end

      def importable_class_sym
        importable_class.to_s.downcase.to_sym
      end

      def relation_factory_params(relation_key, data_hash)
        {
          relation_sym: relation_key.to_sym,
          relation_hash: data_hash,
          importable: @importable,
          members_mapper: @members_mapper,
          object_builder: @object_builder,
          user: @user,
          excluded_keys: excluded_keys_for_relation(relation_key)
        }
      end

      # Temporary fix for https://gitlab.com/gitlab-org/gitlab/-/issues/27883 when import from legacy project.json
      # This should be removed once legacy JSON format is deprecated.
      # Ndjson export file will fix the order during project export.
      def fix_ci_pipelines_not_sorted_on_legacy_project_json!
        return unless relation_reader.legacy?

        relation_reader.relations['ci_pipelines']&.sort_by! { |hash| hash['id'] }
      end
    end
  end
end
