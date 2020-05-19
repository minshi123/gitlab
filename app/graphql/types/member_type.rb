# frozen_string_literal: true

module Types
  class MemberType < BaseObject
    graphql_name 'Member'

    field :access_level, GraphQL::INT_TYPE, null: false
    field :source_type, GraphQL::STRING_TYPE, null: false
    field :created_by, Types::UserType, null: true
    field :created_at, Types::TimeType, null: false
    field :updated_at, Types::TimeType, null: false
    field :expires_at, Types::TimeType, null: true
    field :source, Types::SourceType, null: false # This could be a union type for project/group?

  end
end
