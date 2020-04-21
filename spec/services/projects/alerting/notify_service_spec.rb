# frozen_string_literal: true

require 'spec_helper'

describe Projects::Alerting::NotifyService do
  let_it_be(:project, reload: true) { create(:project) }

  before do
    # We use `let_it_be(:project)` so we make sure to clear caches
    project.clear_memoization(:licensed_feature_available)
  end

  shared_examples 'processes incident issues' do |amount|
    let(:create_incident_service) { spy }

    it 'processes issues' do
      expect(IncidentManagement::ProcessAlertWorker)
        .to receive(:perform_async)
        .with(project.id, kind_of(Hash), new_alert.id)
        .exactly(amount).times

      Sidekiq::Testing.inline! do
        expect(subject).to be_success
      end
    end
  end

  shared_examples 'sends notification email' do
    let(:notification_service) { spy }

    it 'sends a notification for firing alerts only' do
      expect(NotificationService)
        .to receive(:new)
        .and_return(notification_service)

      expect(notification_service)
        .to receive_message_chain(:async, :prometheus_alerts_fired)

      expect(subject).to be_success
    end
  end

  shared_examples 'does not process incident issues' do
    it 'does not process issues' do
      expect(IncidentManagement::ProcessAlertWorker)
        .not_to receive(:perform_async)

      expect(subject).to be_success
    end
  end

  shared_examples 'does not process incident issues due to error' do |http_status:|
    it 'does not process issues' do
      expect(IncidentManagement::ProcessAlertWorker)
        .not_to receive(:perform_async)

      expect(subject).to be_error
      expect(subject.http_status).to eq(http_status)
    end
  end

  shared_examples 'NotifyService does not call create alert service' do
    it 'does not call AlertManagement::CreateAlertService' do
      subject

      expect(AlertManagement::CreateAlertService).not_to have_received(:new)
    end
  end

  describe '#execute' do
    let(:token) { 'invalid-token' }
    let(:starts_at) { Time.now.change(usec: 0) }
    let(:service) { described_class.new(project, nil, payload) }
    let(:payload_raw) do
      {
        'title' => 'alert title',
        'start_time' => starts_at.rfc3339
      }
    end
    let(:payload) { ActionController::Parameters.new(payload_raw).permit! }
    let(:create_alert_service) { instance_double(AlertManagement::CreateAlertService) }

    subject { service.execute(token) }

    before do
      allow(AlertManagement::CreateAlertService)
        .to receive(:new)
        .with(project, payload_raw, payload_parser: Gitlab::Alerting::NotificationPayloadParser)
        .and_return(create_alert_service)
    end

    context 'with activated Alerts Service' do
      let!(:alerts_service) { create(:alerts_service, project: project) }

      context 'with valid token' do
        let(:token) { alerts_service.token }
        let(:incident_management_setting) { double(send_email?: email_enabled, create_issue?: issue_enabled) }
        let(:email_enabled) { false }
        let(:issue_enabled) { false }
        let(:new_alert) { instance_double(AlertManagement::Alert, id: 503) }
        let(:create_alert_response) { ServiceResponse.success(payload: new_alert) }

        before do
          allow(service)
            .to receive(:incident_management_setting)
            .and_return(incident_management_setting)

          allow(create_alert_service).to receive(:execute).and_return(create_alert_response)
        end

        context 'with valid payload' do
          it 'calls create alert service' do
            subject

            expect(create_alert_service).to have_received(:execute)
          end

          it 'returns success' do
            expect(subject).to be_success
          end

          it 'returns created alert' do
            expect(subject.payload).to eq(new_alert)
          end
        end

        context 'with invalid payload' do
          let(:create_alert_response) { ServiceResponse.error(message: 'Bad request', http_status: :bad_request) }

          it 'calls create alert service' do
            subject

            expect(create_alert_service).to have_received(:execute)
          end

          it 'returns bad request' do
            expect(subject).to be_error
            expect(subject.http_status).to eq(:bad_request)
          end
        end

        it_behaves_like 'does not process incident issues'

        context 'issue enabled' do
          let(:issue_enabled) { true }

          it_behaves_like 'processes incident issues', 1

          context 'with an invalid payload' do
            before do
              allow(Gitlab::Alerting::NotificationPayloadParser)
                .to receive(:call)
                .and_raise(Gitlab::Alerting::NotificationPayloadParser::BadPayloadError)
            end

            it_behaves_like 'does not process incident issues due to error', http_status: :bad_request
          end
        end

        context 'with emails turned on' do
          let(:email_enabled) { true }

          it_behaves_like 'sends notification email'
        end
      end

      context 'with invalid token' do
        it_behaves_like 'does not process incident issues due to error', http_status: :unauthorized
        it_behaves_like 'NotifyService does not call create alert service'
      end

      context 'with deactivated Alerts Service' do
        let!(:alerts_service) { create(:alerts_service, :inactive, project: project) }

        it_behaves_like 'does not process incident issues due to error', http_status: :forbidden
        it_behaves_like 'NotifyService does not call create alert service'
      end
    end
  end
end
