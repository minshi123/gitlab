# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Metrics::Dashboard::Stages::EndpointInserter do
  include MetricsDashboardHelpers

  let(:project) { build_stubbed(:project) }
  let(:environment) { build_stubbed(:environment, project: project) }

  describe '#transform!' do
    subject(:transform!) { described_class.new(project, dashboard, environment: environment).transform! }

    let(:dashboard) { load_sample_dashboard.deep_symbolize_keys }

    context 'when dashboard panels are present' do
      it 'assigns unique ids to each panel using PerformanceMonitoring::PrometheusPanel', :aggregate_failures do
        endpoint_path = Gitlab::Routing.url_helpers.prometheus_api_project_environment_path(
          project,
          environment,
          proxy_path: 'series',
          match: ['backend:haproxy_backend_availability:ratio{env="{{env}}"}']
        )

        transform!

        expect(
          dashboard.dig(:templating, :variables, :metric_label_values_variable, :options)
        ).to include(prometheus_endpoint_path: endpoint_path)
      end
    end
  end
end
