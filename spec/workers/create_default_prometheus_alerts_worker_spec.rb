# frozen_string_literal: true

require 'spec_helper'

describe CreateDefaultPrometheusAlertsWorker do
  let_it_be(:project) { create(:project) }
  let_it_be(:environment) { create(:environment, project: project) }
  let(:expected_alerts) { Prometheus::CreateDefaultAlertService::DEFAULT_ALERTS }

  before do
    expected_alerts.each do |alert_hash|
      create(:prometheus_metric, :common, identifier: alert_hash.fetch(:identifier))
    end
  end

  it 'creates the default alerts' do
    expect { described_class.new.perform(project.id) }
      .to change { project.reload.prometheus_alerts.count }
      .by(expected_alerts.size)
  end
end
