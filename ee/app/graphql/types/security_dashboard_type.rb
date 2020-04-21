# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class SecurityDashboardType < BaseObject
    graphql_name 'SecurityDashboard'

    field :projects,
          Types::ProjectType.connection_type,
          null: false,
          resolver: Resolvers::SecurityDashboard::ProjectsResolver,
          description: 'Projects selected in Instance Security Dashboard'
  end
  # rubocop: enable Graphql/AuthorizeTypes
end
