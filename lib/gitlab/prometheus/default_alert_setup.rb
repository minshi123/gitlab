# frozen_string_literal: true

module Gitlab
  module Prometheus
    class DefaultAlertSetup
      attr_reader :project

      def initialize(project:)
        @project = project
      end

      def execute
        environment = project.environments.first

        return unless environment

        default_errors.each do |error|
          metric = PrometheusMetric.for_project(nil).for_identifier(error[:identifier]).first

          next if metric.nil?
          next if PrometheusAlert.for_metric(metric).exists?

          alert = PrometheusAlert.new(
            project: project,
            prometheus_metric: metric,
            environment: environment,
            threshold: error[:threshold],
            operator: error[:operator]
          )
          alert.save
        end
      end

      private

      def default_errors
        [
          alert_ingress_http_error_rate
        ]
      end

      def alert_ingress_http_error_rate
        {
          identifier: 'response_metrics_nginx_ingress_16_http_error_rate',
          operator: 'gt',
          threshold: 0.1
        }
      end
    end
  end
end
