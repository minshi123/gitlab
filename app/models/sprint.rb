# frozen_string_literal: true

class Sprint < ApplicationRecord
  include Timebox

  STATE_ID_MAP = {
      active: 1,
      closed: 2
  }.with_indifferent_access.freeze

  include AtomicInternalId

  has_many :issues
  has_many :merge_requests

  belongs_to :project
  belongs_to :group

  has_internal_id :iid, scope: :project, init: ->(s) { s&.project&.sprints&.maximum(:iid) }
  has_internal_id :iid, scope: :group, init: ->(s) { s&.group&.sprints&.maximum(:iid) }

  state_machine :state_id, initial: :active do
    event :close do
      transition active: :closed
    end

    event :activate do
      transition closed: :active
    end

    state :active, value: Sprint::STATE_ID_MAP[:active]
    state :closed, value: Sprint::STATE_ID_MAP[:closed]
  end

  # Alias to state machine .with_state_id method
  # This needs to be defined after the state machine block to avoid errors
  class << self
    alias_method :with_state, :with_state_id
    alias_method :with_states, :with_state_ids
  end

  def state
    STATE_ID_MAP.key(state_id)
  end

  def state=(value)
    self.state_id = STATE_ID_MAP[value]
  end
end
