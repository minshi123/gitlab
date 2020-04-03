# frozen_string_literal: true

module Resolvers
  class BurndownChartDataResolver
    type [Types::ChartDataSeriesItemType], null: true

    argument :start_time, GraphQL::INT_TYPE, null: false, description: 'Start time of requested time frame'
    argument :end_time, GraphQL::INT_TYPE, null: false, description: 'End time of requested time frame'

    def ready?(**args)
      start_time = args[:start_time]
      end_time = args[:end_time]

      check_negative_values!(start_time, end_time)
      check_maximum_time_frame!(start_time, end_time)

      super(args)
    end

    def resolve(**args)
      # TODO
    end

    private

    def check_negative_values!(start_time, end_time)
      if start_time < 0 || end_time < 0
        raise Gitlab::Graphql::Errors::ArgumentError, "Invalid time frame: #{start_time} / #{end_time}."
      end
    end

    def check_maximum_time_frame!(start_time, end_time)
      if end_time - start_time >= 2.years
        raise Gitlab::Graphql::Errors::ArgumentError, "Time frame exceeds maximum time range: #{start_time} / #{end_time}."
      end
    end
  end
end
