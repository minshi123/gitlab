# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Alerting::NotificationPayloadParser do
  describe '.call' do
    subject { described_class.call(payload) }

    let(:payload) do
      {
        'title' => 'alert title',
        'start_time' => Time.current,
        'description' => 'Description',
        'monitoring_tool' => 'Monitoring tool name',
        'service' => 'Service',
        'hosts' => ['gitlab.com'],
        'severity' => 'low'
      }
    end

    describe 'fingerprint' do
      context 'license feature enabled' do
        before do
          stub_licensed_features(generic_alert_fingerprinting: true)
        end

        it 'generates the fingerprint from the payload' do
          fingerprint_payload = payload.excluding('start_time', 'hosts')
          expected_fingerprint = Gitlab::AlertManagement::Fingerprint.generate(fingerprint_payload)

          expect(subject.dig('annotations', 'fingerprint')).to eq(expected_fingerprint)
        end

        context 'payload has no values' do
          let(:payload) do
            {
              'start_time' => Time.current,
              'hosts' => ['gitlab.com'],
              'title' => ' '
            }
          end

          it 'does not generate the fingerprint from the payload' do
            expect(subject.dig('annotations', 'fingerprint')).to eq(nil)
          end
        end
      end

      context 'license feature not enabled' do
        it 'does not generate the fingerprint from the payload' do
          expect(subject.dig('annotations', 'fingerprint')).to eq(nil)
        end
      end
    end
  end
end
