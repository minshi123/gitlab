# frozen_string_literal: true

module Sprints
  class CreateService < Sprints::BaseService
    def execute
      sprint = parent.sprints.new(params)

      sprint
    end
  end
end
