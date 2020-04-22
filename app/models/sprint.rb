# frozen_string_literal: true

class Sprint < ApplicationRecord
  include Timebox

  has_internal_id :iid, scope: :project, track_if: -> { !importing? }, init: ->(s) { s&.project&.sprints&.maximum(:iid) }
  has_internal_id :iid, scope: :group, track_if: -> { !importing? }, init: ->(s) { s&.group&.sprints&.maximum(:iid) }
end
