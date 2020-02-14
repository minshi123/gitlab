# frozen_string_literal: true

module Geo
  module BlobReplicatorStrategy
    extend ActiveSupport::Concern

    included do
      event :created
    end

    class_methods do
    end

    # Called by Packages::PackageFile on create
    def publish_created_event
      publish(:created, **created_params)

      calculate_checksum if needs_checksum?
    end

    # Called by Gitlab::Geo::Replicator#consume
    def consume_created_event
      download
    end

    def carrierwave_uploader
      raise NotImplementedError
    end

    private

    def download
      ::Geo::BlobDownloadService.new(replicator: self).execute
    end

    def calculate_checksum
      ::Geo::BlobVerificationPrimaryService.new(replicator: self).execute
    end

    def created_params
      { model_record_id: model_record.id }
    end

    def needs_checksum?
      false
    end
  end
end
