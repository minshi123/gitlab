# frozen_string_literal: true

module Gitlab
  module UsageDataCounters
    class SearchCounter < BaseCounter
      KNOWN_EVENTS = %w[all_searches_count].map(&:freeze).freeze
      PREFIX = "global_search"
      NAVBAR_SEARCHES_COUNT_KEY = 'NAVBAR_SEARCHES_COUNT'

      class << self
        def increment_navbar_searches_count
          increment(NAVBAR_SEARCHES_COUNT_KEY)
        end

        def total_navbar_searches_count
          total_count(NAVBAR_SEARCHES_COUNT_KEY)
        end

        def totals
          super.merge({ navbar_searches: total_navbar_searches_count })
        end

        def fallback_totals
          super.merge({ navbar_searches: -1 })
        end
      end
    end
  end
end
