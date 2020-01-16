# frozen_string_literal: true

module Projects
  module Settings
    class WebhooksController < Projects::ApplicationController
      before_action :authorize_admin_project!
      layout 'project_settings'

      def show
        @hooks = @project.hooks
        @hook = ProjectHook.new
      end
    end
  end
end
