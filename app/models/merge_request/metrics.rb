# frozen_string_literal: true

class MergeRequest::Metrics < ApplicationRecord
  belongs_to :merge_request
  belongs_to :pipeline, class_name: 'Ci::Pipeline', foreign_key: :pipeline_id
  belongs_to :latest_closed_by, class_name: 'User'
  belongs_to :merged_by, class_name: 'User'

  def review_time
    return unless first_comment_at

    (merged_at || Time.now) - first_comment_at
  end
end
