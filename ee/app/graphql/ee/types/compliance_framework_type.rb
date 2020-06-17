# frozen_string_literal: true

module EE
  module Types
    class ComplianceFrameworkType < ::Types::BaseObject
      graphql_name 'ComplianceFramework'
      description 'Represents a ComplianceFramework associated with a Project'

      field :name, GraphQL::STRING_TYPE,
            null: false,
            description: 'Name of the compliance framework',
            method: :framework
    end
  end
end
