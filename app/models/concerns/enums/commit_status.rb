# frozen_string_literal: true

module Enums
  module CommitStatus
    extend ActiveSupport::Concern

    included do
      # We use `Enums::CommitStatus.failure_reasons` here so that EE can more easily
      # extend this `Hash` with new values.
      enum_with_nil failure_reason: self.failure_reasons
    end

    class_methods do
      # Returns the Hash to use for creating the `failure_reason` enum for
      # `CommitStatus`.
      def failure_reasons
        {
          unknown_failure: nil,
          script_failure: 1,
          api_failure: 2,
          stuck_or_timeout_failure: 3,
          runner_system_failure: 4,
          missing_dependency_failure: 5,
          runner_unsupported: 6,
          stale_schedule: 7,
          job_execution_timeout: 8,
          archived_failure: 9,
          unmet_prerequisites: 10,
          scheduler_failure: 11,
          data_integrity_failure: 12,
          forward_deployment_failure: 13,
          insufficient_bridge_permissions: 1_001,
          downstream_bridge_project_not_found: 1_002,
          invalid_bridge_trigger: 1_003,
          bridge_pipeline_is_child_pipeline: 1_006,
          downstream_pipeline_creation_failed: 1_007
        }
      end
    end
  end
end

Enums::CommitStatus.prepend_if_ee('EE::Enums::CommitStatus')
