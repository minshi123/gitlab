# frozen_string_literal: true

FactoryBot.define do
  factory :metrics_dashboard_annotation, class: '::Metrics::Dashboard::Annotation' do
    description { "Dashbaord annoation description" }
    dashboard_id { "custom_dashbaord.yml" }
    from { Time.current }
    environment

    trait :with_cluster do
      cluster
      environment { nil }
    end
  end
end
