# frozen_string_literal: true

class UpdateBuildMinutesService < BaseService
  def execute(build)
    return unless build.shared_runners_minutes_limit_enabled?
    return unless build.complete?
    return unless build.duration

    duration_with_cost_factors = accumulated_seconds(build)

    ProjectStatistics.update_counters(project_statistics,
      shared_runners_seconds: duration_with_cost_factors)

    NamespaceStatistics.update_counters(namespace_statistics,
      shared_runners_seconds: duration_with_cost_factors)
  end

  private

  def accumulated_seconds(build)
    if Gitlab.com? # cost factors are related to gitlab.com only
      build.duration
    else
      build.duration
    end
  end

  def namespace_statistics
    namespace.namespace_statistics || namespace.create_namespace_statistics
  end

  def project_statistics
    project.statistics || project.create_statistics(namespace: project.namespace)
  end

  def namespace
    project.shared_runners_limit_namespace
  end
end
