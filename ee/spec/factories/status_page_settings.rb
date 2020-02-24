# frozen_string_literal: true

FactoryBot.define do
  factory :status_page_setting, class: StatusPageSetting do
    project
    aws_s3_bucket_name { 'bucket' }
    aws_region { 'ap-southeast-2' }
    aws_access_key { 'access' }
    aws_secret_key { SecureRandom.hex(10) }
    enabled { false }

    trait :enabled do
      enabled { true }
    end
  end
end
