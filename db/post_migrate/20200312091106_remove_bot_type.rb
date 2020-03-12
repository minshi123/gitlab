# frozen_string_literal: true

class RemoveBotType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_column :users, :bot_type
    end
  end

  def down
    with_lock_retries do
      add_column :users, :bot_type, :integer, limit: 2
    end
  end
end
