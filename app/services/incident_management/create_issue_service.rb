# frozen_string_literal: true

module IncidentManagement
  class CreateIssueService < BaseService
    include Gitlab::Utils::StrongMemoize
    include IncidentManagement::Settings

    attr_reader :alert

    def initialize(project, alert)
      super(project, User.alert_bot)
      @alert = alert.present
    end

    def execute
      return error('setting disabled') unless incident_management_setting.create_issue?
      return error('invalid alert') unless alert.valid?

      result = create_incident
      return error(result.message, result.payload[:issue]) unless result.success?

      result
    end

    private

    def create_incident
      ::IncidentManagement::Incidents::CreateService.new(
        project,
        current_user,
        title: alert.title,
        description: alert.issue_description
      ).execute
    end

    def error(message, issue = nil)
      log_error(%{Cannot create incident issue for "#{project.full_name}": #{message}})

      ServiceResponse.error(payload: { issue: issue }, message: message)
    end
  end
end
