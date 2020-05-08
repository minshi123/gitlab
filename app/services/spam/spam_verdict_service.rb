# frozen_string_literal: true

module Spam
  class SpamVerdictService
    include AkismetMethods
    include SpamConstants

    def initialize(target:, request:, options:, verdict_params: {})
      @target = target
      @request = request
      @options = options
      @verdict_params = assemble_verdict_params(verdict_params)
    end

    def execute
      verdict = spam_verdict
      akismet_result = akismet_verdict

      return ALLOW if verdict.blank? && akismet_result.blank?

      # Favour the most restrictive result.
      # This also treats nils - such as service unavailable - as ALLOW
      VALID_VERDICTS.each do |result|
        return result if [verdict, akismet_result].include? result
      end
    end

    private

    attr_reader :target, :request, :options, :verdict_params, :endpoint_url

    def akismet_verdict
      if akismet.spam?
        Gitlab::Recaptcha.enabled? ? REQUIRE_RECAPTCHA : DISALLOW
      else
        ALLOW
      end
    end

    def spam_verdict
      return if endpoint_url.blank?

      result = Gitlab::HTTP.try_get(endpoint_url, verdict_params)
      return unless result

      json_result = JSON.parse(result).with_indifferent_access
      #@TODO metrics/logging
      # Expecting:
      # error: (string or nil)
      # result: (string or nil)
      verdict = json_result[:verdict]
      return unless VALID_VERDICTS.include?(verdict)
      # log if json_result[:error]

      json_result[:verdict]
    end

    def assemble_verdict_params(params)
      return {} unless endpoint_url

      {
          user_id: target.author_id
      }
    end

    def endpoint_url
      @endpoint_url ||= Gitlab::CurrentSettings.current_application_settings.spam_check_endpoint
    end
  end
end
