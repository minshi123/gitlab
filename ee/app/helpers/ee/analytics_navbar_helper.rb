# frozen_string_literal: true

module EE
  module AnalyticsNavbarHelper
    extend ::Gitlab::Utils::Override

    def project_analytics_navbar_links(project, current_user)
      super + [
        insights_navbar_link(project, current_user),
        code_review_analytics_navbar_link(project, current_user)
      ].compact
    end

    def group_analytics_navbar_links(group, current_user)
      super + [
        group_insights_navbar_link(group, current_user),
        issues_analytics_navbar_link(group, current_user)
      ].compact
    end

    private

    def group_insights_navbar_link(group, current_user)
      return unless ::Feature.enabled?(:analytics_pages_under_group_analytics_sidebar, group)
      return unless group_sidebar_link?(:group_insights)

      title = _('Insights')
      path = 'groups/insights#show'
      link = group_insights_path(group)

      content = nav_link(path: path) do
        link_to link, title: title, class: 'shortcuts-group-insights', data: { qa_selector: 'group_insights_link' } do
          content_tag(:span, title)
        end
      end

      { path: path, content: content, link: link, title: title }
    end

    def issues_analytics_navbar_link(group, current_user)
      return unless ::Feature.enabled?(:analytics_pages_under_group_analytics_sidebar, group)
      return unless group_sidebar_link?(:analytics)

      title = _('Issues Analytics')
      path = 'issues_analytics#show'
      link = group_issues_analytics_path(group)

      content = nav_link(path: path) do
        link_to link do
          content_tag(:span, title)
        end
      end

      { path: path, content: content, link: link, title: title }
    end

    def insights_navbar_link(project, current_user)
      return unless ::Feature.enabled?(:analytics_pages_under_project_analytics_sidebar, project)
      return unless project_nav_tab?(:project_insights)

      title = _('Insights')
      path = 'insights#show'
      link = project_insights_path(project)

      content = nav_link(path: path) do
        link_to(link, title: title, class: 'shortcuts-project-insights', data: { qa_selector: 'project_insights_link' }) do
          content_tag(:span, title)
        end
      end

      { path: path, content: content, link: link, title: title }
    end

    def code_review_analytics_navbar_link(project, current_user)
      return unless project_nav_tab?(:code_review)

      title = _('Code Review')
      path = 'projects/analytics/code_reviews#index'
      link = project_analytics_code_reviews_path(project)

      content = nav_link(path: path) do
        link_to(link, title: title) do
          content_tag(:span, title)
        end
      end

      { path: path, content: content, link: link, title: title }
    end
  end
end
