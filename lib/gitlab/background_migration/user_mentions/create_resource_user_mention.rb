# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    module UserMentions
      class CreateResourceUserMention
        # Resources that have mentions to be migrated:
        # issue, merge_request, epic, commit, snippet, design

        BULK_INSERT_SIZE = 5000
        ISOLATION_MODULE = 'Gitlab::BackgroundMigration::UserMentions::Models'

        def perform(resource_model, join, conditions, with_notes, start_id, end_id)
          resource_model = "#{ISOLATION_MODULE}::#{resource_model}".constantize if resource_model.is_a?(String)
          model = with_notes ? "#{ISOLATION_MODULE}::Note".constantize : resource_model
          resource_user_mention_model = resource_model.user_mention_model

          records = model.joins(join).where(conditions).where(id: start_id..end_id)

          records.in_groups_of(BULK_INSERT_SIZE, false).each do |records|
            filter_missing_records!(records, resource_model, with_notes)

            mentions = []
            records.each do |record|
              mentions << record.build_mention_values
            end

            Gitlab::Database.bulk_insert(
              resource_user_mention_model.table_name,
              mentions,
              return_ids: true,
              disable_quote: resource_model.no_quote_columns,
              on_conflict: :do_nothing
            )
          end
        end

        private

        def filter_missing_records!(records, resource_model, with_notes)
          return unless with_notes

          records_ids = records.pluck(:noteable_id)
          actual_records_ids = resource_model.where(id: records_ids).pluck(:id)
          records.select! { |r| actual_records_ids.include?(r.noteable_id) }
        end
      end
    end
  end
end
