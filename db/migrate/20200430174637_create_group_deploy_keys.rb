# frozen_string_literal: true

class CreateGroupDeployKeys < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    with_lock_retries do
      create_table :group_deploy_keys do |t|
        t.references :user
        t.timestamps_with_timezone
        t.datetime_with_timezone :last_used_at
        t.datetime_with_timezone :expires_at
        t.text :key, null: false, unique: true
        t.text :title
        t.text :fingerprint, null: false, unique: true
        t.binary :fingerprint_sha256
      end
    end

    add_text_limit(:group_deploy_keys, :key, 2048)
    add_text_limit(:group_deploy_keys, :title, 255)
    add_text_limit(:group_deploy_keys, :fingerprint, 255)

    add_concurrent_index :group_deploy_keys, :fingerprint, unique: true
    add_concurrent_index :group_deploy_keys, :fingerprint_sha256

    add_concurrent_foreign_key(:group_deploy_keys, :users, column: :user_id, on_delete: :restrict)
  end

  def down
    drop_table :group_deploy_keys
  end
end
