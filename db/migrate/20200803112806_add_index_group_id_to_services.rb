# frozen_string_literal: true

class AddIndexGroupIdToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :services, :group_id

    add_concurrent_foreign_key :services, :namespaces, column: :group_id, on_delete: :nullify
  end

  def down
    remove_foreign_key_if_exists :services, column: :group_id

    remove_concurrent_index :services, :group_id
  end
end
