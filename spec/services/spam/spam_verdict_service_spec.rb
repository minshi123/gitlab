# frozen_string_literal: true

require 'spec_helper'

describe Spam::SpamVerdictService do
  include_context 'includes Spam constants'

  let(:fake_ip) { '1.2.3.4' }
  let(:fake_user_agent) { 'fake-user-agent' }
  let(:fake_referrer) { 'fake-http-referrer' }
  let(:env) do
    { 'action_dispatch.remote_ip' => fake_ip,
      'HTTP_USER_AGENT' => fake_user_agent,
      'HTTP_REFERRER' => fake_referrer }
  end
  let(:request) { double(:request, env: env) }

  let(:check_for_spam) { true }
  let(:issue) { build(:issue) }
  let(:service) do
    described_class.new(target: issue, request: request, options: {})
  end

  describe '#execute' do
    subject { service.execute }

    context 'if both services return nil' do

    end
  end

  describe '#akismet_verdict' do
    subject { service.send(:akismet_verdict) }

    context 'if Akismet is enabled' do
      before do
        stub_application_setting(akismet_enabled: true)
        allow_next_instance_of(Spam::AkismetService) do |service|
          allow(service).to receive(:spam?).and_return(akismet_result)
        end
      end

      context 'if Akismet considers it spam' do
        let(:akismet_result) { true }

        context 'if reCAPTCHA is enabled' do
          before do
            stub_application_setting(recaptcha_enabled: true)
          end

          it 'returns require reCAPTCHA verdict' do
            expect(subject).to eq REQUIRE_RECAPTCHA
          end
        end

        context 'if reCAPTCHA is not enabled' do
          before do
            stub_application_setting(recaptcha_enabled: false)
          end

          it 'renders disallow verdict' do
            expect(subject).to eq DISALLOW
          end
        end
      end

      context 'if Akismet does not consider it spam' do
        let(:akismet_result) { false }

        it 'renders allow verdict' do
          expect(subject).to eq ALLOW
        end
      end
    end

    context 'if Akismet is not enabled' do
      before do
        stub_application_setting(akismet_enabled: false)
      end

      it 'renders allow verdict' do
        expect(subject).to eq ALLOW
      end
    end
  end

  describe '#spam_verdict' do
    subject { service.send(:spam_verdict) }

    context 'if a Spam Check endpoint is set' do
      let(:spam_check_body) { {} }
      let(:spam_check_http_status) { nil }

      before do
        stub_application_setting(spam_check_endpoint: "http://www.spamcheckurl.com/spam_check")
        stub_request(:any, /.*spamcheckurl.com.*/).to_return( body: spam_check_body.to_json, status: spam_check_http_status )
      end

      context 'if the endpoint is accessible' do
        let(:spam_check_http_status) { 200 }
        let(:error) { nil }
        let(:verdict) { nil }
        let(:spam_check_body) do
          { verdict: verdict, error: error }
        end

        context 'the result is a valid verdict' do
          let(:verdict) { 'allow' }

          it 'returns the verdict' do
            expect(subject).to eq ALLOW
          end
        end

        context 'the verdict is an unexpected string' do
          let(:verdict) { 'this is fine' }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'the verdict is an empty string' do
          let(:verdict) { '' }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'the verdict is nil' do
          let(:verdict) { nil }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'there is an error' do
          let(:error) { "Sorry Dave, I can't do that" }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'the HTTP status is not 200' do
          let(:spam_check_http_status) { 500 }

          it 'returns nil' do
            expect(subject).to be_nil
          end
        end

        context 'the confused API endpoint returns both an error and a verdict' do
          let(:verdict) { 'disallow' }
          let(:error) { 'oh noes!' }

          it 'renders the verdict' do
            expect(subject).to eq DISALLOW
          end
        end
      end

      context 'if the endpoint times out' do
        before do
          stub_request(:any, /.*spamcheckurl.com.*/).to_timeout
        end

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end
    end
  end
end
