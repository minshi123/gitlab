# frozen_string_literal: true

module AlertManagement
  class SetAlertAssigneesService
    # @param alert [AlertManagement::Alert]
    # @param current_user [User]
    # @param assignee_usernames [Array<String>]
    # @param operation_mode [String], one of Types::MutationOperationModeEnum
    def initialize(alert, current_user, assignee_usernames:, operation_mode:)
      @alert = alert
      @current_user = current_user
      @assignee_usernames = assignee_usernames
      @operation_mode = operation_mode
    end

    def execute
      return error_no_permissions unless allowed?
      return error_multiple_assigness if multiple_assignees?
      return error_unsupported_operation unless supported_operation?

      case operation_mode
      when 'REPLACE' then replace
      when 'APPEND' then append
      when 'REMOVE' then remove
      end

      success
    end

    private

    attr_reader :alert, :current_user, :assignee_usernames, :operation_mode

    def allowed?
      current_user.can?(:update_alert_management_alert, alert)
    end

    def supported_operation?
      Types::MutationOperationModeEnum.values.key?(operation_mode)
    end

    def target_users
      UsersFinder.new(current_user, username: assignee_usernames).execute
    end

    def append
      alert.assignees << (target_users - alert.assignees)
    end

    def remove
      alert.assignees = alert.assignees - target_users
    end

    def replace
      alert.assignees = target_users
    end

    def error_no_permissions
      error(_('You have no permissions'))
    end

    def error_unsupported_operation
      error(_('Unsupported operation mode'))
    end

    # TODO: Fully support multiple assignees in EE, but
    # don't block development for now
    def error_multiple_assigness
      error(_('Only one assignee is currently supported'))
    end

    # See #error_multiple_assigness
    def multiple_assignees?
      if operation_mode == 'REPLACE'
        true if assignee_usernames.length > 1
      elsif operation_mode == 'APPEND'
        true if (alert.assignees.map(&:username) + assignee_usernames).uniq.length > 1
      else
        false
      end
    end

    def success
      ServiceResponse.success(payload: { alert: alert })
    end

    def error(message)
      ServiceResponse.error(payload: { alert: alert }, message: message)
    end
  end
end
