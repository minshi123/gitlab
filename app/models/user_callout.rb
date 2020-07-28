# frozen_string_literal: true

class UserCallout < ApplicationRecord
  include Enums::UserCallout

  belongs_to :user

  validates :user, presence: true
  validates :feature_name,
    presence: true,
    uniqueness: { scope: :user_id },
    inclusion: { in: UserCallout.feature_names.keys }

  scope :with_feature_name, -> (feature_name) { where(feature_name: UserCallout.feature_names[feature_name]) }
  scope :with_dismissed_after, -> (dismissed_after) { where('dismissed_at > ?', dismissed_after) }
end
