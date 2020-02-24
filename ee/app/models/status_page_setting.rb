# frozen_string_literal: true

class StatusPageSetting < ApplicationRecord
  belongs_to :project

  attr_encrypted :aws_secret_key,
    mode:      :per_attribute_iv,
    algorithm: 'aes-256-gcm',
    key:       Settings.attr_encrypted_db_key_base_32

  validates :aws_s3_bucket_name,
            length: { minimum: 3, maximum: 63 }
  validates :aws_region, presence: true
  validates :aws_access_key, :project, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }

  def aws_masked_secret_key
    mask(encrypted_aws_secret_key)
  end

  private

  def aws_secret_key
    decrypt(:aws_secret_key, encrypted_aws_secret_key)
  end
end
