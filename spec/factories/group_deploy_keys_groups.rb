# frozen_string_literal: true

FactoryBot.define do
  factory :group_deploy_keys_group do
    group_deploy_key
    group

    trait :write_access do
      can_push { true }
    end
  end
end
