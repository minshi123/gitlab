# frozen_string_literal: true

class CreateGroupDeployKeys < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless table_exists?(:group_deploy_keys)
      create_table :group_deploy_keys do |t|
        t.references :user
        t.timestamps_with_timezone
        t.text :key, null: false
        t.text :title
        t.text :fingerprint
        t.datetime_with_timezone :last_used_at
        t.binary :fingerprint_sha256
        t.datetime_with_timezone :expires_at
      end
    end

    add_text_limit(:group_deploy_keys, :key, 255)
    add_text_limit(:group_deploy_keys, :title, 255)
    add_text_limit(:group_deploy_keys, :fingerprint, 255)

    add_concurrent_index :group_deploy_keys, :fingerprint
    add_concurrent_index :group_deploy_keys, :fingerprint_sha256
  end

  def down
    drop_table :group_deploy_keys
  end
end
