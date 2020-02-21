# frozen_string_literal: true

module Milestoneish
  include Timebox

  def group_milestone?
    false
  end

  def project_milestone?
    false
  end

  def legacy_group_milestone?
    false
  end

  def dashboard_milestone?
    false
  end

  def global_milestone?
    false
  end
end
