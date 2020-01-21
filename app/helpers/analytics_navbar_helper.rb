# frozen_string_literal: true

module AnalyticsNavbarHelper
  prepend_if_ee('::EE::AnalyticsNavbarHelper') # rubocop: disable Cop/InjectEnterpriseEditionModule

  def project_analytics_navbar_links(project, current_user)
    [
      cycle_analytics_navbar_link(project, current_user),
      repository_analytics_navbar_link(project, current_user),
      ci_cd_analytics_navbar_link(project, current_user)
    ].compact
  end

  def group_analytics_navbar_links(group, current_user)
    [
      contribution_analytics_navbar_link(group, current_user)
    ].compact
  end

  private

  def contribution_analytics_navbar_link(group, current_user)
    return unless Feature.enabled?(:analytics_pages_under_group_analytics_sidebar, group)
    return unless group_sidebar_link?(:contribution_analytics)

    title = _('Contribution Analytics')
    path = 'groups/contribution_analytics#show'
    link = group_contribution_analytics_path(group)

    content = nav_link(path: path) do
      link_to link, title: title, data: { placement: 'right', qa_selector: 'contribution_analytics_link' } do
        content_tag(:span, title)
      end
    end
    
    { path: path, content: content, link: link, title: title }
  end

  def cycle_analytics_navbar_link(project, current_user)
    return unless Feature.enabled?(:analytics_pages_under_project_analytics_sidebar, project)
    return unless project_nav_tab?(:cycle_analytics)

    title = _('Cycle Analytics')
    path = 'cycle_analytics#show'
    link = project_cycle_analytics_path(project)

    content = nav_link(path: path) do
      link_to(link, title: title, class: 'shortcuts-project-cycle-analytics') do
        content_tag(:span, title)
      end
    end

    { path: path, content: content, link: link, title: title }
  end

  def repository_analytics_navbar_link(project, current_user)
    return if Feature.disabled?(:analytics_pages_under_project_analytics_sidebar, project)
    return if project.empty_repo?

    title = _('Repository Analytics')
    path = 'graphs#charts'
    link = charts_project_graph_path(project, current_ref)

    content = nav_link(path: path) do
      link_to(link, title: title, class: 'shortcuts-repository-charts') do
        content_tag(:span, title)
      end
    end

    { path: path, content: content, link: link, title: title }
  end

  def ci_cd_analytics_navbar_link(project, current_user)
    return unless Feature.enabled?(:analytics_pages_under_project_analytics_sidebar, project)
    return unless project_nav_tab?(:pipelines)
    return unless project.feature_available?(:builds, current_user) || !project.empty_repo?

    title = _('CI / CD Analytics')
    path = 'pipelines#charts'
    link = charts_project_pipelines_path(project)

    content = nav_link(path: path) do
      link_to(link, title: title, class: 'shortcuts-pipelines-charts') do
        content_tag(:span, title)
      end
    end

    { path: path, content: content, link: link, title: title }
  end
end
