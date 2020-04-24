# frozen_string_literal: true

module Mutations
  module Branches
    class CreateBranch < Base
      include Mutations::ResolvesProject

      graphql_name 'CreateBranch'

      argument :ref,
               GraphQL::STRING_TYPE,
               required: true,
               description: 'Branch name or commit SHA to create branch from'

      authorize :push_code

      def resolve(project_path:, branch:, ref:)
        project = find_project!(project_path: project_path)

        result = ::Branches::CreateService.new(project, current_user)
                   .execute(branch, ref)

        {
          branch: (result[:branch] if result[:status] == :success),
          errors: Array.wrap(result[:message])
        }
      end

      private

      def find_project!(project_path:)
        authorized_find!(full_path: project_path)
      end

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
