# frozen_string_literal: true

class ResourceWeightEvent < ApplicationRecord
  include Gitlab::Utils::StrongMemoize

  validates :user, presence: true
  validates :issue, presence: true

  belongs_to :user
  belongs_to :issue

  scope :by_issue, ->(issue) { where(issue_id: issue.id) }
  scope :created_after, ->(time) { where('created_at > ?', time) }

  def discussion_id(resource = nil)
    strong_memoize(:discussion_id) do
      Digest::SHA1.hexdigest(discussion_id_key.join("-"))
    end
  end

  private

  # We want the created_at precission to miliseconds because we are creating
  # a second `weight event` for historical data, when the newly created `weight event`
  # is the first one for given resource. Both `weight events` may be created within same second,
  # so the generated `discussion_id` ends up being exactly the same if generated based on
  # `created_at` down to seconds precission only.
  #
  # @see EE::ResourceEvents::ChangeWeightService#resource_weight_changes for duplicate `weight event`
  def discussion_id_key
    [self.class.name, created_at.strftime('%Y-%m-%d %H:%M:%S.%N'), user_id]
  end
end
