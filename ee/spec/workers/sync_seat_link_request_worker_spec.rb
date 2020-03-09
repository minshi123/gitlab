# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SyncSeatLinkRequestWorker, type: :worker do
  describe '#perform' do
    subject do
      described_class.new.perform('2020-01-01', '123', 5)
    end

    it 'makes an HTTP POST request with passed params' do
      response = double(success?: true, code: 200)
      allow(Gitlab::HTTP).to receive(:post).and_return(response)

      subject

      expect(Gitlab::HTTP).to have_received(:post)
        .with(
          '/api/v1/seat_links',
          base_uri: EE::SUBSCRIPTIONS_URL,
          headers: { 'Content-Type' => 'application/json' },
          body: {
            date: '2020-01-01',
            license_key: '123',
            max_historical_user_count: 5
          }.to_json
        )
    end

    context 'when the request is not successful' do
      before do
        response = double(success?: false, code: 400, body: '{"success":false,"error":"Bad Request"}')
        allow(Gitlab::HTTP).to receive(:post).and_return(response)
      end

      it { expect { subject }.to raise_error(described_class::RequestError) }
    end
  end
end
