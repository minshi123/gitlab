# frozen_string_literal: true

module EE
  module Boards
    module Lists
      class UpdateLimitMetrics < BaseMutation
        graphql_name 'BoardListUpdateListMetrics'

        authorize :read_list

        argument :limit_metric, # TODO: enum type
                 GraphQL::INT_TYPE,
                 required: false,
                 description: 'The new limit metric type for the list.'

        argument :max_issue_count,
                 GraphQL::INT_TYPE,
                 required: false,
                 description: 'The new maximum issue count limit.'

        argument :max_issue_weight,
                 GraphQL::INT_TYPE,
                 required: false,
                 description: 'The new maximum issue weight limit.'

        def resolve(list_id:, limit_metric:, maximum_issue_count:, maximum_issue_weight:)
          # TODO

          {
            list: nil,
            errors: []
          }
        end
      end
    end
  end
end
