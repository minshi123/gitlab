# frozen_string_literal: true

module Gitlab
  module SeatLinkData
    extend self

    def data(date: report_date, key: license_key, max_users: max_historical_user_count, active_users: active_user_count)
      {
        date: date,
        license_key: key,
        max_historical_user_count: max_users,
        active_users: active_users
      }
    end

    def report_date
      Time.now.utc.yesterday.to_date
    end

    def license_key
      ::License.current.data
    end

    def max_historical_user_count(date: report_date)
      HistoricalData.max_historical_user_count(
        from: ::License.current.starts_at,
        to: date
      )
    end

    def active_user_count(date: report_date)
      HistoricalData.at(date)&.active_user_count
    end
  end
end
