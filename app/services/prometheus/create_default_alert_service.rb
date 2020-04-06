# frozen_string_literal: true

module Prometheus
  class CreateDefaultAlertService < BaseService
    include Gitlab::Utils::StrongMemoize

    attr_reader :project

    def self.alert_ingress_16_http_error_rate
      {
        identifier: 'response_metrics_nginx_ingress_16_http_error_rate',
        operator: 'gt',
        threshold: 0.1
      }
    end

    def self.alert_ingress_http_error_rate
      {
        identifier: 'response_metrics_nginx_ingress_http_error_rate',
        operator: 'gt',
        threshold: 0.1
      }
    end

    DEFAULT_ALERTS = [
      alert_ingress_http_error_rate,
      alert_ingress_16_http_error_rate
    ].freeze

    def initialize(project:)
      @project = project
    end

    def execute
      return unless project
      return unless environment

      metric_identifiers = DEFAULT_ALERTS.map { |alert| alert[:identifier] }
      metrics_by_identifier = PrometheusMetricsFinder.new(identifier: metric_identifiers, common: true).execute.index_by(&:identifier)
      alerts_by_identifier = Projects::Prometheus::AlertsFinder.new(project: project, metric: metrics_by_identifier.values).execute.index_by { |alert| alert.prometheus_metric.identifier }

      DEFAULT_ALERTS.each do |alert_hash|
        identifier = alert_hash[:identifier]
        next if alerts_by_identifier.key?(identifier)

        metric = metrics_by_identifier[identifier]
        next unless metric

        create_alert(error: alert_hash, metric: metric)
      end
    end

    private

    def environment
      environments = EnvironmentsFinder.new(project, name: 'production').find ||
        project.environments

      environments.first
    end

    def create_alert(error:, metric:)
      PrometheusAlert.create!(
        project: project,
        prometheus_metric: metric,
        environment: environment,
        threshold: error[:threshold],
        operator: error[:operator]
      )
    rescue ActiveRecord::RecordNotUnique
      # Ignore duplicate creations although it unlikely to happen
    end
  end
end
