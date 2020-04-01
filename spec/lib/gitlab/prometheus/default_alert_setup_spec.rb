# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Prometheus::DefaultAlertSetup do
  let_it_be(:project) { create(:project) }
  let_it_be(:instance) { described_class.new(project: project) }
  let(:expected_alerts) { instance.send(:default_alerts) }

  describe '#execute' do
    subject(:execute_setup) { instance.execute }

    shared_examples 'no alerts created' do
      it 'does not create alerts' do
        execute_setup
        expect(project.prometheus_alerts.count).to eq(0)
      end
    end

    context 'no environment' do
      it_behaves_like 'no alerts created'
    end

    context 'environment exists' do
      let_it_be(:environment) { create(:environment, project: project) }

      context 'no found metric' do
        it_behaves_like 'no alerts created'
      end

      context 'metric exists' do
        before do
          create_expected_metrics!
        end

        context 'alert exists already' do
          before do
            create_pre_existing_alerts!
          end

          it_behaves_like 'no alerts created'
        end

        it 'creates alerts' do
          execute_setup
          expect(project.prometheus_alerts.count).to eq(expected_alerts.size)
        end
      end
    end
  end

  private

  def create_expected_metrics!
    expected_alerts.each do |error|
      create(:prometheus_metric, :common, identifier: error.fetch(:identifier))
    end
  end

  def create_pre_existing_alerts!
    expected_alerts.each do |error|
      metric = PrometheusMetric.for_identifier(error[:identifier]).first
      create(:prometheus_alert, prometheus_metric: metric)
    end
  end
end
