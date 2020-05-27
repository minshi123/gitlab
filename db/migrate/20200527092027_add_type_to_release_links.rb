# frozen_string_literal: true

class AddTypeToReleaseLinks < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :release_links, :type, :integer, default: 0
    end
  end
  
  def down
    with_lock_retries do
      remove_column :release_links, :type
    end
  end
end
