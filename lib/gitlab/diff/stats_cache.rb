# frozen_string_literal: true
#
module Gitlab
  module Diff
    class StatsCache
      include Gitlab::Metrics::Methods
      include Gitlab::Utils::StrongMemoize

      EXPIRATION = 1.week
      VERSION = 1

      delegate :diffable, to: :@diff_collection

      def initialize(diff_collection)
        @diff_collection = diff_collection
      end

      def read
        strong_memoize(:cached_values) do
          Rails.cache.fetch(key)
        end
      end

      def write(stats)
        if !@cached_values && stats
          Rails.cache.write(key, stats, expires_in: EXPIRATION)
        end
      end

      def clear
        Gitlab::Redis::Cache.with do |redis|
          redis.del(key)
        end
      end

      def key
        strong_memoize(:redis_key) do
          ['diff_stats', diffable.cache_key, VERSION].join(":")
        end
      end
    end
  end
end
