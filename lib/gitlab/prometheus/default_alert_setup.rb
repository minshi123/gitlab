# frozen_string_literal: true

module Gitlab
  module Prometheus
    class DefaultAlertSetup
      attr_reader :project

      def initialize(project:)
        @project = project
      end

      def execute
        return unless project
        return unless environment

        default_alerts.each do |alert_hash|
          metric = metric_for_identifer(alert_hash[:identifier])
          next if metric.nil?

          create_alert(error: alert_hash, metric: metric)
        end
      end

      private

      def environment
        project.environments.for_name('production').first ||
          project.environments.first
      end

      def metric_for_identifer(id)
        metric = PrometheusMetric.common.for_identifier(id).first
        return if PrometheusAlert.for_metric(metric).exists?

        metric
      end

      def create_alert(error:, metric:)
        PrometheusAlert.create!(
          project: project,
          prometheus_metric: metric,
          environment: environment,
          threshold: error[:threshold],
          operator: error[:operator]
        )
      end

      def default_alerts
        [
          alert_ingress_http_error_rate,
          alert_ingress_16_http_error_rate
        ]
      end

      def alert_ingress_16_http_error_rate
        {
          identifier: 'response_metrics_nginx_ingress_16_http_error_rate',
          operator: 'gt',
          threshold: 0.1
        }
      end

      def alert_ingress_http_error_rate
        {
          identifier: 'response_metrics_nginx_ingress_http_error_rate',
          operator: 'gt',
          threshold: 0.1
        }
      end
    end
  end
end
