# frozen_string_literal: true
class AddScannedResourcesCountToSecurityScan < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column_with_default(:security_scans, :scanned_resources_count, :integer, default: 0, allow_null: false)
  end

  def down
    remove_column :security_scans, :scanned_resources_count
  end
end
