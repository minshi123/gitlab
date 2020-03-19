# frozen_string_literal: true

module Metrics
  module Dashboard
    class Annotation < ApplicationRecord
      self.table_name = 'metrics_dashboard_annotations'

      belongs_to :environment, inverse_of: :metrics_dashboard_annotations
      belongs_to :cluster, class_name: 'Clusters::Cluster', inverse_of: :metrics_dashboard_annotations

      validates :from, presence: true
      validates :description, presence: true, length: { maximum: 255 }
      validates :dashboard_id, presence: true, length: { maximum: 255 }
      validates :panel_id, length: { maximum: 255 }
      validate :orphaned_annotation

      private

      def orphaned_annotation
        return if cluster_id || environment_id

        errors.add(:base, s_('Metrics::Dashboard::Annotation|Annotation must belong to a cluster or an environment'))
      end
    end
  end
end
