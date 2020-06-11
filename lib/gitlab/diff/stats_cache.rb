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
          Gitlab::Redis::Cache.with do |redis|
            encoded_stats = redis.hmget(key, file_paths).compact
            encoded_stats.present? && Gitlab::Git::DiffStatsCollection.new(encoded_stats.map { |stat| decode_stat(stat) })
          end
        end
      end

      def write(stats)
        if !@cached_values && stats
          Gitlab::Redis::Cache.with do |redis|
            redis.pipelined do
              stats.each do |stat|
                redis.hset(
                  key,
                  stat.path,
                  encode_stat(stat)
                )
              end

              # HSETs have to have their expiration date manually updated
              #
              redis.expire(key, EXPIRATION)
            end
          end
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

      private

      def encode_stat(stat)
        Gitaly::DiffStats.encode(stat)
      end

      def decode_stat(stat)
        Gitaly::DiffStats.decode(stat)
      end

      def diff_files
        # We access raw_diff_files here, as diff_files will attempt to apply the
        #   highlighting code found in this class, leading  to a circular
        #   reference.
        #
        @diff_collection.raw_diff_files
      end

      def file_paths
        strong_memoize(:file_paths) do
          diff_files.collect(&:file_path)
        end
      end
    end
  end
end
