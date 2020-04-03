# frozen_string_literal: true

# rubocop: disable Graphql/AuthorizeTypes
module Types
  class ChartDataSeriesItemType < BaseObject
    field :time, GraphQL::INT_TYPE, null: false, description: 'Time for this item.'
    field :value, GraphQL::FLOAT_TYPE, null: true, description: 'Value of that time.'
  end
end
