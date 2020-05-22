# frozen_string_literal: true

module Mutations
  module AlertManagement
    class SetAlertAssignees < Base
      graphql_name 'SetAlertAssignees'

      argument :assignee_usernames,
               [GraphQL::STRING_TYPE],
               required: true,
               description: 'The usernames to assign to the merge request. Replaces existing assignees by default.'

      argument :operation_mode,
               Types::MutationOperationModeEnum,
               required: false,
               description: 'The operation to perform. Defaults to REPLACE.'

      def resolve(args)
        alert = authorized_find!(project_path: args[:project_path], iid: args[:iid])
        result = set_assignees(alert, args[:assignee_usernames], args[:operation_mode])

        prepare_response(result)
      end

      private

      def set_assignees(alert, assignee_usernames, operation_mode)
        operation_mode ||= Types::MutationOperationModeEnum.enum[:replace]

        ::AlertManagement::SetAlertAssigneesService
          .new(alert, current_user, assignee_usernames, operation_mode)
          .execute
      end

      def prepare_response(result)
        {
          alert: result.payload[:alert],
          errors: result.error? ? [result.message] : []
        }
      end
    end
  end
end
