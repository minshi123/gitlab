# frozen_string_literal: true

module EE
  module MergeRequestPollCachedWidgetEntity
    extend ActiveSupport::Concern

    prepended do
      expose :merge_train_when_pipeline_succeeds_docs_path do |merge_request|
        presenter(merge_request).merge_train_when_pipeline_succeeds_docs_path
      end

      expose :policy_violation do |_|
        Feature.enabled?(:license_compliance_denies_mr, merge_request.project, default_enabled: false)
      end
    end
  end
end
