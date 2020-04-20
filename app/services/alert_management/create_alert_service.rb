# frozen_string_literal: true

module AlertManagement
  class CreateAlertService < BaseService
    def initialize(project, params)
      @payload_parser = params.fetch(:payload_parser, :invalid_payload_parser)
      @raw_payload = params.except(:payload_parser)
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
        host: annotations[:hosts].join(','), # I think it should be "hosts" https://gitlab.com/gitlab-org/gitlab/-/merge_requests/29864/diffs#note_327373508
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
