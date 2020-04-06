# frozen_string_literal: true

module Prometheus
  class CreateDefaultAlertsService < BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :project

    DEFAULT_ALERTS = [
      {
        identifier: 'response_metrics_nginx_ingress_16_http_error_rate',
        operator: 'gt',
        threshold: 0.1
      },
      {
        identifier: 'response_metrics_nginx_ingress_http_error_rate',
        operator: 'gt',
        threshold: 0.1
      }
    ].freeze

    def initialize(project:)
      @project = project
    end

    def execute
      return ServiceResponse.error(message: 'Invalid project') unless project
      return ServiceResponse.error(message: 'Invalid environment') unless environment

      metric_identifiers = DEFAULT_ALERTS.map { |alert| alert[:identifier] }
      metrics_by_identifier = PrometheusMetricsFinder.new(identifier: metric_identifiers, common: true).execute.index_by(&:identifier)
      alerts_by_identifier = Projects::Prometheus::AlertsFinder.new(project: project, environment: environment, metric: metrics_by_identifier.values).execute.index_by { |alert| alert.prometheus_metric.identifier }

      DEFAULT_ALERTS.each do |alert_hash|
        identifier = alert_hash[:identifier]
        next if alerts_by_identifier.key?(identifier)

        metric = metrics_by_identifier[identifier]
        next unless metric

        create_alert(alert: alert_hash, metric: metric)
      end

      ServiceResponse.success
    end

    private

    def environment
      strong_memoize(:environment) do
        EnvironmentsFinder.new(project, nil, name: 'production').find.first ||
          project.environments.first
      end
    end

    def create_alert(alert:, metric:)
      PrometheusAlert.create!(
        project: project,
        prometheus_metric: metric,
        environment: environment,
        threshold: alert[:threshold],
        operator: alert[:operator]
      )
    rescue ActiveRecord::RecordNotUnique
      # Ignore duplicate creations although it unlikely to happen
    end
  end
end
