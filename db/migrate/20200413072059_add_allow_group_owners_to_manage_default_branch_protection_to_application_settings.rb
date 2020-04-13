# frozen_string_literal: true

class AddAllowGroupOwnersToManageDefaultBranchProtectionToApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  disable_ddl_transaction!

  def up
    add_column_with_default(:application_settings,
                            :allow_group_owners_to_manage_default_branch_protection,
                            :boolean,
                            default: true)
  end

  def down
    remove_column :application_settings, :allow_group_owners_to_manage_default_branch_protection
  end
end
