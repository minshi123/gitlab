# frozen_string_literal: true
#
module Gitlab
  module Diff
    class StatsCache
      include Gitlab::Metrics::Methods
      include Gitlab::Utils::StrongMemoize

      EXPIRATION = 1.week
      VERSION = 1

      def initialize(diffable)
        @diffable = diffable
      end

      def read
        strong_memoize(:cached_values) do
          Rails.cache.fetch(key)
        end
      end

      def write_if_empty(stats)
        if @cached_values.blank? && stats.present?
          Rails.cache.write(key, stats, expires_in: EXPIRATION)
        end
      end

      def clear
        Gitlab::Redis::Cache.with do |redis|
          redis.del(key)
        end
      end

      private

      attr_reader :diffable

      def key
        strong_memoize(:redis_key) do
          ['diff_stats', diffable.cache_key, VERSION].join(":")
        end
      end
    end
  end
end
