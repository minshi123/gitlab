# frozen_string_literal: true

module Types
  class BranchType < BaseObject
    graphql_name 'Branch'
    description 'A branch object'

    field :name,
          GraphQL::STRING_TYPE,
          null: false,
          description: 'The branch name'
  end
end
