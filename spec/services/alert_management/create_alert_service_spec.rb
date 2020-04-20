# frozen_string_literal: true

require 'spec_helper'

describe AlertManagement::CreateAlertService do
  let_it_be(:project) { create(:project, :repository, :private) }
  let(:service) { described_class.new(project, create_alert_params) }

  let(:payload) do
    {
      'title' => 'Alert title',
      'description' => 'Description',
      'monitoring_tool' => 'Monitoring tool name',
      'service' => 'Service',
      'hosts' => ['gitlab.com'],
      'some' => { 'extra' => { 'payload' => 'here' } }
    }
  end

  let(:create_alert_params) { payload.merge(payload_parser: Gitlab::Alerting::NotificationPayloadParser) }

  subject(:create_alert) { service.execute }

  describe '#execute' do
    context 'with valid payload' do
      it 'returns success' do
        is_expected.to be_success
      end

      it 'creates an alert' do
        expect { create_alert }.to change(AlertManagement::Alert, :count).by(1)
      end

      it 'created alert has all data properly assigned' do
        create_alert

        alert = AlertManagement::Alert.last
        alert_attributes = alert.attributes.except('id', 'iid', 'created_at', 'updated_at')

        expect(alert_attributes).to eq(
          'project_id' => project.id,
          'issue_id' => nil,
          'fingerprint' => nil,
          'title' => 'Alert title',
          'description' => 'Description',
          'monitoring_tool' => 'Monitoring tool name',
          'service' => 'Service',
          'host' => 'gitlab.com',
          'payload' => payload,
          'severity' => 'critical',
          'status' => 'triggered',
          'events' => 1,
          'started_at' => alert.started_at,
          'ended_at' => nil
        )
      end
    end

    context 'with invalid payload' do
      before do
        allow(Gitlab::Alerting::NotificationPayloadParser)
          .to receive(:call)
          .and_raise(Gitlab::Alerting::NotificationPayloadParser::BadPayloadError)
      end

      it 'returns error' do
        expect(create_alert).to be_error
        expect(create_alert.http_status).to eq(:bad_request)
      end
    end
  end
end
