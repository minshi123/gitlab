# frozen_string_literal: true

module Types
  class SprintType < BaseObject
    graphql_name 'Sprint'
    description 'Represents a sprint.'

    present_using SprintPresenter

    authorize :read_sprint

    field :id, GraphQL::ID_TYPE, null: false,
          description: 'ID of the sprint'

    field :title, GraphQL::STRING_TYPE, null: false,
          description: 'Title of the sprint'

    field :description, GraphQL::STRING_TYPE, null: true,
          description: 'Description of the sprint'

    field :state, Types::SprintStateEnum, null: false,
          description: 'State of the sprint'

    field :web_path, GraphQL::STRING_TYPE, null: false, method: :sprint_path,
          description: 'Web path of the sprint'

    field :due_date, Types::TimeType, null: true,
          description: 'Timestamp of the sprint due date'

    field :start_date, Types::TimeType, null: true,
          description: 'Timestamp of the sprint start date'

    field :created_at, Types::TimeType, null: false,
          description: 'Timestamp of sprint creation'

    field :updated_at, Types::TimeType, null: false,
          description: 'Timestamp of last sprint update'
  end
end
