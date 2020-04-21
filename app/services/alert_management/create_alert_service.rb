# frozen_string_literal: true

module AlertManagement
  class CreateAlertService < BaseService
    def initialize(project, params, payload_parser:)
      @payload_parser = payload_parser
      @raw_payload = params
      super(project, nil, params)
    end

    def execute
      alert = AlertManagement::Alert.create!(alert_params)

      ServiceResponse.success(payload: alert)
    rescue payload_parser::BadPayloadError
      bad_request
    end

    private

    attr_reader :payload_parser, :raw_payload

    def parsed_payload
      @parsed_payload ||= payload_parser.call(raw_payload).with_indifferent_access
    end

    def alert_params
      {
        project: project,
        started_at: parsed_payload['startsAt'],
        title: annotations[:title],
        description: annotations[:description],
        monitoring_tool: annotations[:monitoring_tool],
        service: annotations[:service],
        hosts: annotations[:hosts],
        payload: raw_payload
      }
    end

    def annotations
      @annotations ||= parsed_payload[:annotations]
    end

    def bad_request
      ServiceResponse.error(message: 'Bad Request', http_status: :bad_request)
    end
  end
end
