# frozen_string_literal: true

module Analytics
  module CycleAnalytics
    class TimeSummaryController < BaseSummaryController
      def summary(group_level)
        group_level.time_summary
      end
    end
  end
end
