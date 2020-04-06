# frozen_string_literal: true

require 'securerandom'

FactoryBot.define do
  factory :import_failure do
    association :project, factory: :project

    correlation_id_value { SecureRandom.uuid }

    trait :hard_failure do
      retry_count { 0 }
    end

    trait :soft_failure do
      retry_count { 1 }
    end
  end
end
