# frozen_string_literal: true

module Mutations
  module MergeRequests
    class Create < BaseMutation
      include Mutations::ResolvesProject

      graphql_name 'CreateMergeRequest'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'Project full path the merge request is associated with'

      argument :title, GraphQL::STRING_TYPE,
               required: true,
               description: 'Title of the merge request'

      argument :source_branch, GraphQL::STRING_TYPE,
               required: true,
               description: 'Source branch'

      argument :target_branch, GraphQL::STRING_TYPE,
               required: true,
               description: 'Target branch'

      field :merge_request,
            Types::MergeRequestType,
            null: true,
            description: "Merge request after mutation"

      authorize :create_merge_request_from

      def resolve(project_path:, title:, source_branch:, target_branch:)
        project = authorized_find!(full_path: project_path)

        attributes = {
          title: title,
          source_branch: source_branch,
          target_branch: target_branch,
          author_id: current_user.id
        }

        merge_request = ::MergeRequests::CreateService.new(project, current_user, attributes).execute

        {
          merge_request: merge_request.valid? ? merge_request : nil,
          errors: merge_request.errors.full_messages
        }
      end

      private

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end
    end
  end
end
