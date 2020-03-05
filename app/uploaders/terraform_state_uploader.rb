# frozen_string_literal: true

class TerraformStateUploader < GitlabUploader
  include ObjectStorage::Concern

  storage_options Gitlab.config.uploads

  delegate :project_id, to: :model

  encrypt(key: :key)

  def filename
    "terraform-state-#{model.id}.tfstate"
  end

  def store_dir
    'tf-state'
  end

  def key
    OpenSSL::HMAC.digest("SHA256", Gitlab::Application.secrets.db_key_base, project_id.to_s)
  end
end
