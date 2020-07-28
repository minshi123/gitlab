# frozen_string_literal: true

module Enums
  module InternalId
    extend ActiveSupport::Concern

    included do
      enum usage: self.usage_resources
    end

    class_methods do
      def usage_resources
        # when adding new resource, make sure it doesn't conflict with EE usage_resources
        {
          issues: 0,
          merge_requests: 1,
          deployments: 2,
          milestones: 3,
          epics: 4,
          ci_pipelines: 5,
          operations_feature_flags: 6,
          operations_user_lists: 7,
          alert_management_alerts: 8,
          sprints: 9 # iterations
        }
      end
    end
  end
end

Enums::InternalId.prepend_if_ee('EE::Enums::InternalId')
