# frozen_string_literal: true

module EE
  module NavHelper
    extend ::Gitlab::Utils::Override

    override :has_extra_nav_icons?
    def has_extra_nav_icons?
      super || can?(current_user, :read_operations_dashboard)
    end

    override :page_has_markdown?
    def page_has_markdown?
      super || current_path?('epics#show')
    end

    override :admin_monitoring_nav_links
    def admin_monitoring_nav_links
      controllers = %w(audit_logs)
      super.concat(controllers)
    end

    override :group_issues_sub_menu_items
    def group_issues_sub_menu_items
      controllers = %w(issues_analytics#show)
      if @group.beta_feature_available?(:iterations) do
        controllers = %w(iterations#index)
      end
      super.concat(controllers)
    end
  end
end
