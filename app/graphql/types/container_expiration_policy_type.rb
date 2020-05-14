# frozen_string_literal: true

module Types
  class ContainerExpirationPolicyType < BaseObject
    graphql_name 'ContainerExpirationPolicy'

    description 'A tag expiration policy designed to keep only the images that matter most'

    authorize :destroy_container_image

    field :project_id, GraphQL::ID_TYPE, null: false, description: 'Project id of this container expiration policy'
    field :created_at, Types::TimeType, null: false, description: 'Timestamp of when the container expiration policy was created'
    field :updated_at, Types::TimeType, null: false, description: 'Timestamp of when the container expiration policy was updated'
    field :enabled, GraphQL::BOOLEAN_TYPE, null: false, description: 'Indicates if this container expiration policy is enabled'
    field :older_than, GraphQL::STRING_TYPE, null: true, description: 'Tags older that this will expire'
    field :cadence, GraphQL::STRING_TYPE, null: false, description: 'This container expiration policy schedule'
    field :keep_n, GraphQL::INT_TYPE, null: true, description: 'Number of tags to retain'
    field :name_regex, GraphQL::STRING_TYPE, null: true, description: 'Tags with names matching this regex pattern will expire'
    field :name_regex_keep, GraphQL::STRING_TYPE, null: true, description: 'Tags with names matching this regex pattern will be preserved'
  end
end
