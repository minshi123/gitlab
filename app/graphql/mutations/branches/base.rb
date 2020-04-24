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

      authorize :update_issue

      private

      def find_object(project_path:, iid:)
        resolve_issuable(type: :issue, parent_path: project_path, iid: iid)
      end
    end
  end
end
