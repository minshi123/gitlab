# frozen_string_literal: true

class AddIndexOnActiveAndTemplateAndTypeAndIdToServices < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :services, [:active, :template, :type, :id]
  end

  def down
    remove_concurrent_index :services, [:active, :template, :type, :id]
  end
end
