# frozen_string_literal: true

module AlertManagement
  class ProcessPrometheusAlertService < BaseService
    def execute
      @parsed_alert = Gitlab::Alerting::Alert.new(project: project, payload: params)
      return bad_request unless parsed_alert.valid?

      process_alert_management_alert

      ServiceResponse.success
    end

    private

    attr_reader :parsed_alert

    delegate :firing?, :resolved?, :gitlab_fingerprint, :ends_at, to: :parsed_alert

    def process_alert_management_alert
      create_alert_management_alert if firing?
      resolve_alert_management_alert if resolved?
    end

    def create_alert_management_alert
      if am_alert.present?
        am_alert.trigger
      else
        AlertManagement::Alert.create(am_alert_params)
      end
    end

    def am_alert_params
      AlertManagement::AlertParams.from_prometheus_alert(project: project, parsed_alert: parsed_alert)
    end

    def resolve_alert_management_alert
      am_alert&.resolve(ended_at: ends_at)
    end

    def am_alert
      # rubocop: disable CodeReuse/ActiveRecord
      @am_alert ||= AlertManagement::Alert.find_by(project: project, fingerprint: gitlab_fingerprint)
      # rubocop: enable CodeReuse/ActiveRecord
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
