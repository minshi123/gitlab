# frozen_string_literal: true

module Geo
  class PackageFileVerificationSecondaryService
    include Delay
    include Gitlab::Geo::LogHelpers

    def initialize(registry)
      @registry = registry
    end

    def execute
      return unless Gitlab::Geo.geo_database_configured?
      return unless Gitlab::Geo.secondary?
      return unless should_verify_checksum?

      verify_checksum
    end

    private

    attr_reader :registry

    def package_file
      registry.package_file
    end

    def should_verify_checksum?
      return false if registry.waiting_for_sync?
      return false unless primary_checksum.present?

      mismatch?(secondary_checksum)
    end

    def primary_checksum
      package_file.verification_checksum
    end

    def secondary_checksum
      registry.verification_checksum_sha
    end

    def mismatch?(checksum)
      primary_checksum != checksum
    end

    def verify_checksum
      checksum = package_file.calculate_checksum!

      if mismatch?(checksum)
        update_registry!(mismatch: checksum, failure: "#{type.to_s.capitalize} checksum mismatch")
      else
        update_registry!(checksum: checksum)
      end
    rescue => e
      update_registry!(failure: "Error calculating #{type} checksum", exception: e)
    end

    def update_registry!(checksum: nil, mismatch: nil, failure: nil, exception: nil)
      reverify, verification_retry_count =
        if mismatch || failure.present?
          log_error(failure, exception, type: type)
          [true, registry.verification_retry_count(type) + 1]
        else
          [false, nil]
        end

      resync_retry_at, resync_retry_count =
        if reverify
          [*calculate_next_retry_attempt(registry, type)]
        end

      registry.update!(
        verification_checksum_sha: checksum,
        verification_checksum_mismatched: mismatch,
        checksum_mismatch: mismatch.present?,
        verified_at: Time.now,
        verification_failure: failure,
        verification_retry_count: verification_retry_count,
        retry_at: resync_retry_at,
        retry_count: resync_retry_count
      )
    end

    def calculate_next_retry_attempt
      retry_count = regisry.retry_count.to_i + 1
      [next_retry_time(retry_count), retry_count]
    end
  end
end
