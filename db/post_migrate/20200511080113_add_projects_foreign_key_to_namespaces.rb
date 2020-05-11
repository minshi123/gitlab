# frozen_string_literal: true

class AddProjectsForeignKeyToNamespaces < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key(
      :projects,
      :namespaces,
      column: :namespace_id,
      on_delete: :restrict,
      validate: false
    )
  end

  def down
    with_lock_retries do
      remove_foreign_key_if_exists :projects, column: :namespace_id
    end
  end
end
