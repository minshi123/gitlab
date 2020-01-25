# frozen_string_literal: true

class Security::VulnerableProjectsController < Security::ApplicationController
  include SecurityDashboardsPermissions

  def index
    vulnerable_projects = VulnerableProjectsFinder.new(vulnerable.projects)

    render json: VulnerableProjectSerializer.new.represent(vulnerable_projects)
  end

  private

  def vulnerable
    InstanceSecurityDashboard.new(current_user)
  end
end
