# frozen_string_literal: true

class Sprint
  include Timebox

  belongs_to :groups
  belongs_to :projects

  def timebox_id
    id
  end
end