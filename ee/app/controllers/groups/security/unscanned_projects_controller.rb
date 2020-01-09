# frozen_string_literal: true

class Groups::Security::UnscannedProjectsController < Groups::ApplicationController
  include SecurityDashboardsPermissions

  alias_method :vulnerable, :group

  def index
    render json: {}
  end
end
