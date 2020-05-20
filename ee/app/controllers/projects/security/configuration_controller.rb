# frozen_string_literal: true

module Projects
  module Security
    class ConfigurationController < Projects::ApplicationController
      include SecurityDashboardsPermissions

      alias_method :vulnerable, :project

      before_action :check_feature_flag

      before_action only: [:show] do
        push_frontend_feature_flag(:security_auto_fix, project, default_enabled: false)
      end

      def show
        @configuration = ConfigurationPresenter.new(project)
      end

      def auto_fix
        setting = project.security_setting || project.create_security_setting
        feature = params[:feature]
        enabled = params[:enabled]

        setting.update("auto_fix_#{feature}", enabled)

        render_ok
      end

      private

      def check_feature_flag
        return render_404 if Feature.disabled?(:security_auto_fix, project, default_enabled: false)
      end
    end
  end
end
