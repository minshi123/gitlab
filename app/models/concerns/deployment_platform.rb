# frozen_string_literal: true

module DeploymentPlatform
  # EE would override this and utilize environment argument
  # rubocop:disable Gitlab/ModuleWithInstanceVariables
  def deployment_platform(environment: nil)
    @deployment_platform ||= {}

    @deployment_platform[environment] ||= find_deployment_platform(environment)
  end

  private

  def find_deployment_platform(environment)
    find_management_cluster(environment) ||
      find_platform_kubernetes_with_cte(environment) ||
      find_instance_cluster_platform_kubernetes(environment: environment)
  end

  # EE would override this and utilize environment argument
  def find_management_cluster(_environment)
    management_clusters.enabled.default_environment.first&.platform_kubernetes
  end

  # EE would override this and utilize environment argument
  def find_platform_kubernetes_with_cte(_environment)
    Clusters::ClustersHierarchy.new(self).base_and_ancestors
      .enabled.default_environment
      .first&.platform_kubernetes
  end

  # EE would override this and utilize environment argument
  def find_instance_cluster_platform_kubernetes(environment: nil)
    Clusters::Instance.new.clusters.enabled.default_environment
      .first&.platform_kubernetes
  end
end
