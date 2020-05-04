# frozen_string_literal: true

class ResourceStateEvent < ResourceEvent
  belongs_to :issue
  belongs_to :merge_request

  validate :exactly_one_issuable

  scope :by_issue, ->(issue) { where(issue_id: issue.id) }
  scope :by_merge_request, ->(merge_request) { where(merge_request_id: merge_request.id) }

  # state is used for issue and merge request states.
  enum state: {
    opened: 1,
    closed: 2,
    merged: 3,
    locked: 4,
    reopened: 5
  }

  def self.issuable_attrs
    %i(issue merge_request).freeze
  end
end
