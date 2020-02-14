# frozen_string_literal: true

module Geo
  class BlobVerificationPrimaryService
    include Delay
    include Gitlab::Geo::LogHelpers

    attr_reader :replicator

    # Initialize a new verification service
    #
    # @param [Gitlab::Geo::Replicator] replicator instance
    def initialize(replicator:)
      @replicator = replicator
    end

    # Calculates a checksum
    #
    # @return [Boolean] true if synced, false if not
    def execute
      checksum = model_record.calculate_checksum!
      update_state!(checksum: checksum)
    rescue => e
      log_error("Error calculating the checksum", e)
      update_state!(failure: e.message)
    end

    private

    def update_state!(checksum: nil, failure: nil)
      retry_at, retry_count =
        if failure.present?
          calculate_next_retry_attempt
        end

      model_record.update!(
        verification_checksum: checksum,
        last_verification_ran_at: Time.now,
        last_verification_failure: failure,
        retry_at: retry_at,
        retry_count: retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = model_record.public_send(:retry_count).to_i + 1 # rubocop:disable GitlabSecurity/PublicSend
      [next_retry_time(retry_count), retry_count]
    end

    def model_record
      replicator.model_record
    end
  end
end
