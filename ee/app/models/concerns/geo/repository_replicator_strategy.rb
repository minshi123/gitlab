# frozen_string_literal: true

module Geo
  module RepositoryReplicatorStrategy
    extend ActiveSupport::Concern

    include Delay
    include Gitlab::Geo::LogHelpers

    included do
      event :updated
      event :deleted
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_updated(**params)
      return unless in_replicables_for_geo_node?

      sync_repository
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_event_deleted(**params)
      return unless in_replicables_for_geo_node?

      replicate_destroy
    end

    def replicate_destroy(event_data)
      ::Geo::SnippetRepositoryRemovalService.new(
        replicable_name,
        model_record.id,
        event_data[:blob_path]
      ).execute
    end

    def sync_repository
      Geo::SnippetRepositorySyncService.new(replicator: self).execute
    end

    def reschedule_sync
      Geo::EventWorker.perform_async(replicable_name, 'updated', {})
    end
  end
end
