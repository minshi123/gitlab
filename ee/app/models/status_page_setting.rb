# frozen_string_literal: true

class StatusPageSetting < ApplicationRecord
  belongs_to :project

  attr_encrypted :aws_secret_key,
    mode:      :per_attribute_iv,
    algorithm: 'aes-256-gcm',
    key:       Settings.attr_encrypted_db_key_base_32

  before_validation :check_token_changes

  validates :aws_s3_bucket_name,
            length: { minimum: 3, maximum: 63 },
            presence: true
  validates :aws_access_key, :project, :aws_region, :encrypted_aws_secret_key,
            presence: true
  validates :enabled, inclusion: { in: [true, false] }

  scope :enabled, -> { where(enabled: true) }

  def masked_aws_secret_key
    mask(encrypted_aws_secret_key)
  end

  def masked_aws_secret_key_was
    mask(encrypted_aws_secret_key_was)
  end

  private

  def check_token_changes
    return unless [encrypted_aws_secret_key_was, masked_aws_secret_key_was].include?(aws_secret_key)

    clear_attribute_changes [:aws_secret_key, :encrypted_aws_secret_key, :encrypted_aws_secret_key_iv]
  end

  def aws_secret_key
    decrypt(:aws_secret_key, encrypted_aws_secret_key)
  end

  def mask(token)
    token&.squish&.gsub(/./, '*')
  end
end
