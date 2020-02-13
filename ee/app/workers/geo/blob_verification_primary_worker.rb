# frozen_string_literal: true

module Geo
    class BlobVerificationPrimaryWorker
      include ApplicationWorker
      include GeoQueue
      include ::Gitlab::Geo::LogHelpers

      sidekiq_options retry: 3, dead: false

      def perform(blob_model, blob_id)
        replicator = blob_model.constantize.find(blob_id).replicator

        replicator.calculate_checksum!
      rescue ActiveRecord::RecordNotFound
        log_error("Couldn't find the blob, skipping", blob_model: blob_model, blob_id: blob_id)
      rescue NameError
        log_error("Blob model not found", blob_model: blob_model)
      end
    end
  end
