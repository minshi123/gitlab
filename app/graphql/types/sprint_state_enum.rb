# frozen_string_literal: true

module Types
  class SprintStateEnum < BaseEnum
    graphql_name 'SprintState'
    description 'State of a GitLab sprint'

    value 'active'
    value 'closed'
  end
end
