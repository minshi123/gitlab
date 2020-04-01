# frozen_string_literal: true

module JiraImport
  class StartImportService
    attr_reader :user, :project, :jira_project_key

    def initialize(user, project, jira_project_key)
      @user = user
      @project = project
      @jira_project_key = jira_project_key
    end

    def execute
      validation_response = validate
      return validation_response if validation_response&.error?

      create_and_schedule_import
    end

    private

    def create_and_schedule_import
      jira_import = project.jira_imports.build(
        user: user,
        jira_project_key: jira_project_key,
        # we do not have the jira project name yet so set it key,
        # we will once https://gitlab.com/gitlab-org/gitlab/-/merge_requests/28190
        jira_project_name: jira_project_key,
        # we do not have the jira project id yet so set it to 0,
        # we will once https://gitlab.com/gitlab-org/gitlab/-/merge_requests/28190
        jira_project_xid: 0
      )
      project.import_type = 'jira'
      project.save! && jira_import.schedule!

      ServiceResponse.success(payload: { import_data: jira_import } )
    rescue => ex
      # in case a last minute error is raised
      Gitlab::ErrorTracking.track_exception(ex, project_id: project.id)
      build_error_response(ex.message)
      # in case jira_import state did get saved we want t set it to failed,
      # so that we do not lock further imports if jira import gets somehow in a scheduled state
      jira_import.do_fail!
    end

    def validate
      return build_error_response(_('Jira import feature is disabled.')) unless Feature.enabled?(:jira_issue_import, project)
      return build_error_response(_('You do not have permissions to run the import.')) unless user.can?(:admin_project, project)
      return build_error_response(_('Jira integration not configured.')) unless project.jira_service&.active?
      return build_error_response(_('Unable to find Jira project to import data from.')) if jira_project_key.blank?
      return build_error_response(_('Jira import is already running.')) if import_in_progress?
    end

    def build_error_response(message)
      ServiceResponse.error(
        message: import_data.errors.full_messages.to_sentence,
        http_status: 400,
      )
    end

    def import_in_progress?
      project.latest_jira_import&.in_progress?
    end
  end
end
