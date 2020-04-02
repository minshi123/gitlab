# frozen_string_literal: true

class SyncSeatLinkWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :analysis

  # Retry for up to approximately 17 hours
  sidekiq_options retry: 12, dead: false

  def perform
    return unless should_sync_seats?

    SyncSeatLinkRequestWorker.perform_async(
      report_date.to_s,
      Gitlab::SeatLinkData.license_key,
      Gitlab::SeatLinkData.max_historical_user_count(date: report_date),
      Gitlab::SeatLinkData.active_user_count(date: report_date)
    )
  end

  private

  # Only sync paid licenses from start date until 14 days after expiration
  # when seat link feature is enabled.
  def should_sync_seats?
    Gitlab::CurrentSettings.seat_link_enabled? &&
      License.current &&
      !License.current.trial? &&
      report_date.between?(License.current.starts_at, License.current.expires_at + 14.days)
  end

  def report_date
    @report_date ||= Gitlab::SeatLinkData.report_date
  end
end
