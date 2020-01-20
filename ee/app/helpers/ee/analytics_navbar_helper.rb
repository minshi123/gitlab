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

    private

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
