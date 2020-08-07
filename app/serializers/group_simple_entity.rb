# frozen_string_literal: true

class GroupSimpleEntity < Grape::Entity
  include RequestAwareEntity

  expose :id
  expose :name
  expose :full_path
  expose :full_name
end
