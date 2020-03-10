# frozen_string_literal: true

class AddIndexOnEnabledAndProviderTypeAndIdToClusters < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :clusters, [:enabled, :provider_type, :id]
  end

  def down
    remove_concurrent_index :clusters, [:enabled, :provider_type, :id]
  end
end
