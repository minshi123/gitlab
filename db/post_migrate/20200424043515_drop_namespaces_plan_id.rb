# frozen_string_literal: true

class DropNamespacesPlanId < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_column :namespaces, :plan_id
  end

  def down
    add_column :namespaces, :plan_id, :integer

    add_concurrent_index :namespaces, :plan_id
    add_concurrent_foreign_key :namespaces, :plans, column: :plan_id, on_delete: :nullify
  end
end
