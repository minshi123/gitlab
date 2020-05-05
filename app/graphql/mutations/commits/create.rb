# frozen_string_literal: true

module Mutations
  module Commits
    class Create < BaseMutation
      include Mutations::ResolvesProject

      graphql_name 'CreateCommit'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Project full path the branch is associated with'

      argument :branch, GraphQL::STRING_TYPE,
               required: true,
               description: 'Name of the branch'

      argument :message,
               GraphQL::STRING_TYPE,
               required: true,
               description: 'Message of the commit'

      argument :actions,
               [Types::CommitActionType],
               required: true,
               description: 'Array of action hashes to commit as a batch'

      field :commit,
            Types::CommitType,
            null: true,
            description: 'Commit after mutation'

      authorize :push_code

      def resolve(project_path:, branch:, message:, actions:)
        project = authorized_find!(full_path: project_path)

        attributes = {
          commit_message: message,
          branch_name: branch,
          start_branch: branch,
          actions: actions.map { |action| action.to_h }
        }

        result = ::Files::MultiService.new(project, current_user, attributes).execute

        commit = result[:status] == :success ? project.repository.commit(result[:result]) : nil

        {
          commit: commit,
          errors: Array.wrap(result[:message])
        }
      end

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
