# frozen_string_literal: true

class MergeRequestAssignee < ApplicationRecord
  belongs_to :merge_request
  belongs_to :assignee, class_name: "User", foreign_key: :user_id

  validates_uniqueness_of :assignee, scope: :merge_request_id
end
