# frozen_string_literal: true

module Gitlab
  module Prometheus
    class DefaultAlertSetup
      attr_reader :project, :cluster

      def initialize(project:, cluster:)
        @project = project
        @cluster = cluster
      end

      def execute
        environment = project.environments.first

        return unless environment

        default_errors.each do |error|
          metric = PrometheusMetric.for_project(nil).for_identifier(error[:identifier])
          next if metric.nil?

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

      def alert_nginx_http_error_rate
        {
          identifier: 'response_metrics_nginx_http_error_rate_TODO',
          query: ''
        }
      end
    end
  end
end
