# frozen_string_literal: true

module IncidentManagement
  class ProcessAlertWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :incident_management
    feature_category :incident_management

    def perform(project_id, alert_payload)
      project = find_project(project_id)
      return unless project

      create_issue(project, alert_payload)
    end

    private

    def find_project(project_id)
      Project.find_by_id(project_id)
    end

    def create_issue(project, alert_payload)
      IncidentManagement::CreateIssueService
        .new(project, alert_payload)
        .execute
    end
  end
end
