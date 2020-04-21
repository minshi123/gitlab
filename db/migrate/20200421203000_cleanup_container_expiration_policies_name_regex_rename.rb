# frozen_string_literal: true

class CleanupContainerExpirationPoliciesNameRegexRename < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    cleanup_concurrent_column_rename(:container_expiration_policies,
                                     :updated_at,
                                     :updated_at_timestamp)
  end

  def down
    undo_cleanup_concurrent_column_rename(:container_expiration_policies,
                                          :updated_at,
                                          :updated_at_timestamp,
                                          batch_column_name: :project_id)
  end
end
