# frozen_string_literal: true

class SyncSeatLinkWorker
  include ApplicationWorker

  # feature_category :source_code_management

  URI_PATH = '/'

  def perform
    binding.pry
    return unless License.current
    make_request
  end

  private

  def make_request
    Gitlab::HTTP.post('/api/v1/seat_links', base_uri: EE::SUBSCRIPTIONS_URL, body: request_body)
  end

  def request_body
    {
      date: Time.at(self['created_at']).utc.to_date.to_s,
      license_key: License.current.data,
      max_historical_user_count: HistoricalData.max_historical_user_count
    }
  end

end
