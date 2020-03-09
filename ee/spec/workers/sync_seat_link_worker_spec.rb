# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SyncSeatLinkWorker, type: :worker do
  describe '#perform' do
    subject do
      described_class.new.perform
    end

    context 'when current, paid license is active' do
      before do
        HistoricalData.create!(date: License.current.starts_at - 1.day, active_user_count: 100)
        HistoricalData.create!(date: License.current.starts_at, active_user_count: 10)
        HistoricalData.create!(date: License.current.starts_at + 1.day, active_user_count: 15)
        HistoricalData.create!(date: Date.current + 3.days, active_user_count: 20)
      end

      it 'executes the SyncSeatLinkRequestWorker with expected params' do
        allow(SyncSeatLinkRequestWorker).to receive(:perform_async).and_return(true)

        subject

        expect(SyncSeatLinkRequestWorker).to have_received(:perform_async)
          .with(
            Date.current.to_s,
            License.current.data,
            15
          )
      end
    end

    context 'when license is missing' do
      before do
        License.current.destroy!
      end

      it 'does not execute the SyncSeatLinkRequestWorker' do
        expect(SyncSeatLinkRequestWorker).not_to receive(:perform_async)

        subject
      end
    end

    context 'when using a trial license' do
      before do
        FactoryBot.create(:license, trial: true)
      end

      it 'does not execute the SyncSeatLinkRequestWorker' do
        expect(SyncSeatLinkRequestWorker).not_to receive(:perform_async)

        subject
      end
    end

    context 'when using an expired license' do
      before do
        gl_license = FactoryBot.create(:gitlab_license, expires_at: expiration_date)
        FactoryBot.create(:license, data: gl_license.export)
      end

      context 'the license expired over 14 days ago' do
        let(:expiration_date) { Date.current - 15.days }

        it 'does not execute the SyncSeatLinkRequestWorker' do
          expect(SyncSeatLinkRequestWorker).not_to receive(:perform_async)

          subject
        end
      end

      context 'the license expired less than or equal to 14 days ago' do
        let(:expiration_date) { Date.current - 14.days }

        it 'does not execute the SyncSeatLinkRequestWorker' do
          expect(SyncSeatLinkRequestWorker).to receive(:perform_async).and_return(true)

          subject
        end
      end
    end
  end
end
