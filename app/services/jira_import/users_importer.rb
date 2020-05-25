# frozen_string_literal: true

module JiraImport
  class UsersImporter
    attr_reader :project, :start_at

    MAX_USERS = 50

    def initialize(project, start_at)
      @project = project
      @start_at = start_at
    end

    def execute
      project.validate_jira_import_settings!

      return if users.blank?

      UsersMapper.new(project, users).execute
    end

    private

    def users
      @users ||= fetch_users
    end

    def fetch_users
      request = "/rest/api/2/users?maxResults=#{MAX_USERS}&startAt=#{start_at}"
      client.get(request)
    rescue => e
      Gitlab::ErrorTracking.track_exception(e, project_id: project.id, request: request)
    end

    def client
      @client ||= project.jira_service.client
    end
  end
end
