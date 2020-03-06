# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SyncSeatLinkWorker, type: :worker do
  describe '#perform' do
    context 'when License is not present' do
      before do
        License.destroy_all
      end

      it 'does not make an HTTP call and returns' do
        expect(Gitlab::HTTP).not_to receive(:post)
        subject.perform
      end
    end

    context 'when the License is present' do
      let!(:license) { create :license }

      before do
        License.reset_current
      end

      context 'when the License is not an expired ' do
        it 'calculates the users historical data and makes a POST request' do
          allow(HistoricalData).to receive(:max_historical_user_count).and_return true
          expect(Gitlab::HTTP).to receive(:post).and_return true
          expect(subject.perform).to be_truthy

          expect(HistoricalData).to have_received(:max_historical_user_count)
        end

        it 'makes a POST request to customers application' do
          allow(HistoricalData).to receive(:max_historical_user_count).and_return true
          expect(Gitlab::HTTP).to receive(:post).with('/api/v1/seat_links', base_uri: EE::SUBSCRIPTIONS_URL, body: anything).and_return true
          expect(subject.perform).to be_truthy

          expect(HistoricalData).to have_received(:max_historical_user_count)
        end

        it "makes a POST request with UTC created_at date, license_key, max_historical_user_count" do
          allow(HistoricalData).to receive(:max_historical_user_count).and_return 10
          body = {
            date: Date.current,
            license_key: license.data,
            max_historical_user_count: 10
          }
          expect(Gitlab::HTTP).to receive(:post).with(anything, hash_including(body: body)).and_return true
          expect(subject.perform).to be_truthy
        end

        context 'when the job is enqueued the next day' do
          fit "makes the POST request using the JOB's created_at" do
            allow(HistoricalData).to receive(:max_historical_user_count).and_return 10
            allow(Gitlab::HTTP).to receive(:post).and_return true

            Sidekiq::Testing.fake! do
              described_class.perform_async
              job = described_class.jobs.last['created_at']
              date = Time.at(job).utc.to_date.to_s

              body = {
                date: date,
                license_key: license.data,
                max_historical_user_count: 10
              }

              expect(Gitlab::HTTP).to have_received(:post).with(anything, hash_including(body: body))
            end
          end
        end
      end
    end
  end
end
