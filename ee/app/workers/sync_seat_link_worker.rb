# frozen_string_literal: true

class SyncSeatLinkWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :analysis

  def perform
    return unless should_sync_seats?

    SyncSeatLinkRequestWorker.perform_async(
      Date.current.to_s,
      License.current.data,
      max_historical_user_count
    )
  end

  private

  # Only sync paid licenses from start date until 14 days after expiration
  def should_sync_seats?
    License.current &&
    !License.current.trial? &&
    Date.current.between?(License.current.starts_at, License.current.expires_at + 14.days)
  end

  def max_historical_user_count
    HistoricalData.max_historical_user_count(
      from: License.current.starts_at,
      to: Date.current
    )
  end
end
