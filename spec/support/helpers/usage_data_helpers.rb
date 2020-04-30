# frozen_string_literal: true

module UsageDataHelpers
  SMAU_KEYS = %i(
      snippet_create
      snippet_update
      snippet_comment
      merge_request_comment
      merge_request_create
      commit_comment
      wiki_pages_create
      wiki_pages_update
      wiki_pages_delete
      web_ide_views
      web_ide_commits
      web_ide_merge_requests
      web_ide_previews
      navbar_searches
      cycle_analytics_views
      productivity_analytics_views
      source_code_pushes
    ).freeze

  COUNTS_KEYS = %i(
      assignee_lists
      boards
      ci_builds
      ci_internal_pipelines
      ci_external_pipelines
      ci_pipeline_config_auto_devops
      ci_pipeline_config_repository
      ci_runners
      ci_triggers
      ci_pipeline_schedules
      auto_devops_enabled
      auto_devops_disabled
      deploy_keys
      deployments
      successful_deployments
      failed_deployments
      environments
      clusters
      clusters_enabled
      project_clusters_enabled
      group_clusters_enabled
      instance_clusters_enabled
      clusters_disabled
      project_clusters_disabled
      group_clusters_disabled
      instance_clusters_disabled
      clusters_platforms_eks
      clusters_platforms_gke
      clusters_platforms_user
      clusters_applications_helm
      clusters_applications_ingress
      clusters_applications_cert_managers
      clusters_applications_prometheus
      clusters_applications_crossplane
      clusters_applications_runner
      clusters_applications_knative
      clusters_applications_elastic_stack
      clusters_applications_jupyter
      clusters_management_project
      in_review_folder
      grafana_integrated_projects
      groups
      issues
      issues_created_from_gitlab_error_tracking_ui
      issues_with_associated_zoom_link
      issues_using_zoom_quick_actions
      issues_with_embedded_grafana_charts_approx
      incident_issues
      keys
      label_lists
      labels
      lfs_objects
      merge_requests
      milestone_lists
      milestones
      notes
      pool_repositories
      projects
      projects_imported_from_github
      projects_asana_active
      projects_jira_active
      projects_jira_server_active
      projects_jira_cloud_active
      projects_slack_notifications_active
      projects_slack_slash_active
      projects_slack_active
      projects_slack_slash_commands_active
      projects_custom_issue_tracker_active
      projects_mattermost_active
      projects_prometheus_active
      projects_with_repositories_enabled
      projects_with_error_tracking_enabled
      projects_with_alerts_service_enabled
      projects_with_prometheus_alerts
      pages_domains
      protected_branches
      releases
      remote_mirrors
      snippets
      suggestions
      todos
      uploads
      web_hooks
    ).push(*SMAU_KEYS)

  USAGE_DATA_KEYS = %i(
      active_user_count
      counts
      recorded_at
      edition
      version
      installation_type
      uuid
      hostname
      mattermost_enabled
      signup_enabled
      ldap_enabled
      gravatar_enabled
      omniauth_enabled
      reply_by_email_enabled
      container_registry_enabled
      dependency_proxy_enabled
      gitlab_shared_runners_enabled
      gitlab_pages
      git
      gitaly
      database
      avg_cycle_analytics
      influxdb_metrics_enabled
      prometheus_metrics_enabled
      web_ide_clientside_preview_enabled
      ingress_modsecurity_enabled
      projects_with_expiration_policy_disabled
      projects_with_expiration_policy_enabled
      projects_with_expiration_policy_enabled_with_keep_n_unset
      projects_with_expiration_policy_enabled_with_older_than_unset
      projects_with_expiration_policy_enabled_with_keep_n_set_to_1
      projects_with_expiration_policy_enabled_with_keep_n_set_to_5
      projects_with_expiration_policy_enabled_with_keep_n_set_to_10
      projects_with_expiration_policy_enabled_with_keep_n_set_to_25
      projects_with_expiration_policy_enabled_with_keep_n_set_to_50
      projects_with_expiration_policy_enabled_with_keep_n_set_to_100
      projects_with_expiration_policy_enabled_with_cadence_set_to_1d
      projects_with_expiration_policy_enabled_with_cadence_set_to_7d
      projects_with_expiration_policy_enabled_with_cadence_set_to_14d
      projects_with_expiration_policy_enabled_with_cadence_set_to_1month
      projects_with_expiration_policy_enabled_with_cadence_set_to_3month
      projects_with_expiration_policy_enabled_with_older_than_set_to_7d
      projects_with_expiration_policy_enabled_with_older_than_set_to_14d
      projects_with_expiration_policy_enabled_with_older_than_set_to_30d
      projects_with_expiration_policy_enabled_with_older_than_set_to_90d
      object_store
    ).freeze

  def stub_object_store_settings
    allow(Settings).to receive(:[]).with('artifacts')
      .and_return(
        { 'enabled' => true,
         'object_store' =>
         { 'enabled' => true,
          'remote_directory' => 'artifacts',
          'direct_upload' => true,
          'connection' =>
         { 'provider' => 'AWS', 'aws_access_key_id' => 'minio', 'aws_secret_access_key' => 'gdk-minio', 'region' => 'gdk', 'endpoint' => 'http://127.0.0.1:9000', 'path_style' => true },
           'background_upload' => false,
           'proxy_download' => false } }
      )

    allow(Settings).to receive(:[]).with('external_diffs').and_return({ 'enabled' => false })

    allow(Settings).to receive(:[]).with('lfs')
      .and_return(
        { 'enabled' => true,
         'object_store' =>
         { 'enabled' => false,
          'remote_directory' => 'lfs-objects',
          'direct_upload' => true,
          'connection' =>
         { 'provider' => 'AWS', 'aws_access_key_id' => 'minio', 'aws_secret_access_key' => 'gdk-minio', 'region' => 'gdk', 'endpoint' => 'http://127.0.0.1:9000', 'path_style' => true },
           'background_upload' => false,
           'proxy_download' => false } }
      )
    allow(Settings).to receive(:[]).with('uploads')
      .and_return(
        { 'object_store' =>
          { 'enabled' => false,
          'remote_directory' => 'uploads',
          'direct_upload' => true,
          'connection' =>
          { 'provider' => 'AWS', 'aws_access_key_id' => 'minio', 'aws_secret_access_key' => 'gdk-minio', 'region' => 'gdk', 'endpoint' => 'http://127.0.0.1:9000', 'path_style' => true },
           'background_upload' => false,
           'proxy_download' => false } }
      )
    allow(Settings).to receive(:[]).with('packages')
      .and_return(
        { 'enabled' => true,
         'object_store' =>
         { 'enabled' => false,
          'remote_directory' => 'packages',
          'direct_upload' => false,
          'connection' =>
         { 'provider' => 'AWS', 'aws_access_key_id' => 'minio', 'aws_secret_access_key' => 'gdk-minio', 'region' => 'gdk', 'endpoint' => 'http://127.0.0.1:9000', 'path_style' => true },
           'background_upload' => true,
           'proxy_download' => false } }
      )
  end
end
