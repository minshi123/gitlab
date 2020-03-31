# frozen_string_literal: true

module API
  module Entities
    class Annotation < Grape::Entity
      expose :id
      expose :from
      expose :to
      expose :dashboard_id
      expose :panel_id
      expose :description
      expose :environment_id
      expose :cluster_id
    end
  end
end
