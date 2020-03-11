# frozen_string_literal: true

class AddUserStateIndex < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    remove_concurrent_index_by_name(:users, 'index_users_on_state_and_internal_ee')
    add_concurrent_index(:users, :state, where: 'ghost IS NOT TRUE AND user_type IS NULL', name: 'index_users_on_state_and_internal_ee')
  end

  def down
    remove_concurrent_index_by_name(:users, 'index_users_on_state_and_internal_ee')
    add_concurrent_index(:users, :state, where: 'ghost IS NOT TRUE AND bot_type IS NULL', name: 'index_users_on_state_and_internal_ee')
  end
end
