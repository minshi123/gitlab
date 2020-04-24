# frozen_string_literal: true

module Mutations
  module Branches
    class Base < BaseMutation
      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: "The project the branch to mutate is in"

      argument :branch, GraphQL::STRING_TYPE,
               required: true,
               description: "The name of the branch"

      field :branch,
            Types::BranchType,
            null: true,
            description: "The branch after mutation"
    end
  end
end
