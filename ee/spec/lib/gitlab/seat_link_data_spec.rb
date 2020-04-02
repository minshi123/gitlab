# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::SeatLinkData do
  let(:utc_time) { Time.utc(2020, 3, 12, 12, 00) }

  # Setting the date as 12th March 2020 12:00 UTC for tests and creating new license
  let!(:current_license) { create_current_license(starts_at: '2020-02-12'.to_date)}

  around do |example|
    Timecop.travel(utc_time) { example.run }
  end

  def seed_historical_data
    HistoricalData.create!(date: '2020-02-12'.to_date, active_user_count: 10)
    HistoricalData.create!(date: '2020-02-13'.to_date, active_user_count: 15)
    HistoricalData.create!(date: '2020-03-11'.to_date, active_user_count: 12)
    HistoricalData.create!(date: '2020-03-12'.to_date, active_user_count: 20)
  end

  describe '.data' do
    before do
      seed_historical_data
    end

    context 'when passing no params' do
      it 'returns payload data using defaults' do
        expect(described_class.data).to eq(
          {
            date: '2020-03-11'.to_date,
            license_key: current_license.data,
            max_historical_user_count: 15,
            active_users: 12
          }
        )
      end
    end

    context 'when passing params' do
      it 'returns payload data using defaults' do
        date = '2020-03-22'.to_date

        payload = described_class.data(date: date, key: 'key', max_users: 10, active_users: 5)

        expect(payload).to eq(
          {
            date: date,
            license_key: 'key',
            max_historical_user_count: 10,
            active_users: 5
          }
        )
      end
    end
  end

  describe '.report_date' do
    it "returns yesterday's date" do
      expect(described_class.report_date).to eq('2020-03-11'.to_date)
    end
  end

  describe '.license_key' do
    it 'returns the key of the current license' do
      expect(described_class.license_key).to eq(current_license.data)
    end
  end

  describe '.max_historical_user_count' do
    before do
      seed_historical_data
    end

    context 'when passing no params' do
      it 'returns the max historical user count from the license start to the default end date' do
        expect(described_class.max_historical_user_count).to eq(15)
      end
    end

    context 'when passing no params' do
      it 'returns the max historical user count from the license start to the default end date' do
        expect(described_class.max_historical_user_count(date: '2020-03-12'.to_date)).to eq(20)
      end
    end
  end

  describe '.active_user_count' do
    before do
      seed_historical_data
    end

    context 'when passing no params' do
      it 'returns the max historical user count from the license start to the default end date' do
        expect(described_class.active_user_count).to eq(12)
      end
    end

    context 'when passing no params' do
      it 'returns the max historical user count from the license start to the default end date' do
        expect(described_class.active_user_count(date: '2020-02-12'.to_date)).to eq(10)
      end
    end
  end
end
