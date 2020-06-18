# frozen_string_literal: true

module EE
  module Gitlab
    module Alerting
      module NotificationPayloadParser
        extend ::Gitlab::Utils::Override

        EXCLUDED_PAYLOAD_FINGERPRINT_PARAMS = %w(start_time hosts).freeze

        # Currently we use full payloads, when generating a fingerprint.
        # This results in a quite strict fingerprint.
        # Over time we can relax these rules.
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/214557#note_362795447
        override :fingerprint
        def fingerprint
          super if payload[:fingerprint].present?

          # TODO Scope by project
          return unless License.feature_available?(:gitlab_alert_fingerprinting) &&
                        ::Feature.enabled?(:gitlab_alert_fingerprinting)

          payload_excluding_params = payload.excluding(EXCLUDED_PAYLOAD_FINGERPRINT_PARAMS)

          ::Gitlab::AlertManagement::Fingerprint.generate(payload_excluding_params)
        end
      end
    end
  end
end
