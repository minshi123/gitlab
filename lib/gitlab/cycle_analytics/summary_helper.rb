# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module SummaryHelper
      def frequency(count, from, to)
        return Gitlab::CycleAnalytics::Summary::Value::NoValue.new if count.zero?

        freq = (count / days(from, to)).round(1)

        Gitlab::CycleAnalytics::Summary::Value::NumericValue.new(freq)
      end

      def days(from, to)
        [(to.end_of_day - from.beginning_of_day).fdiv(1.day), 1].max
      end
    end
  end
end
