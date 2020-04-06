# frozen_string_literal: true

class ImportFailure < ApplicationRecord
  belongs_to :project
  belongs_to :group

  validates :project, presence: true, unless: :group
  validates :group, presence: true, unless: :project

  scope :hard_failures, ->(correlation_id) {
    where(correlation_id_value: correlation_id, retry_count: 0).order(created_at: :desc)
  }
end
