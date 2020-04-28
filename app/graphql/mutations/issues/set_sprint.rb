# frozen_string_literal: true

module Mutations
  module Issues
    class SetSprint < Base
      graphql_name 'IssueSetSprint'

      argument :sprint_id,
               GraphQL::ID_TYPE,
               required: false,
               loads: Types::SprintType,
               description: <<~DESC
                            The sprint to assign to the issue.
               DESC

      def resolve(project_path:, iid:, sprint: nil)
        issue = authorized_find!(project_path: project_path, iid: iid)
        project = issue.project

        ::Issues::UpdateService.new(project, current_user, sprint: sprint)
          .execute(issue)

        {
          issue: issue,
          errors: issue.errors.full_messages
        }
      end
    end
  end
end
