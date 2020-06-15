# frozen_string_literal: true

module Gitlab
  module Diff
    module FileCollection
      class MergeRequestDiffBase < Base
        extend ::Gitlab::Utils::Override

        def initialize(merge_request_diff, diff_options:)
          @merge_request_diff = merge_request_diff

          super(merge_request_diff,
            project: merge_request_diff.project,
            diff_options: diff_options,
            diff_refs: merge_request_diff.diff_refs,
            fallback_diff_refs: merge_request_diff.fallback_diff_refs)
        end

        def diff_files
          strong_memoize(:diff_files) do
            diff_files = super

            diff_files.each { |diff_file| highlight_cache.decorate(diff_file) }

            diff_files
          end
        end

        override :write_cache
        def write_cache
          highlight_cache.write_if_empty
          diff_stats_cache.write_if_empty(diff_stats_collection)
        end

        override :clear_cache
        def clear_cache
          highlight_cache.clear
          diff_stats_cache.clear
        end

        def real_size
          @merge_request_diff.real_size
        end

        private

        def highlight_cache
          @highlight_cache ||= Gitlab::Diff::HighlightCache.new(self)
        end

        def diff_stats_cache
          @diff_stats_cache ||= Gitlab::Diff::StatsCache.new(@merge_request_diff)
        end

        def diff_stats_collection
          strong_memoize(:diff_stats) do
            # There are scenarios where we don't need to request Diff Stats,
            # when caching for instance.
            next unless @include_stats
            next unless diff_refs

            cached = diff_stats_cache.read
            cached || @repository.diff_stats(diff_refs.base_sha, diff_refs.head_sha)
          end
        end
      end
    end
  end
end
