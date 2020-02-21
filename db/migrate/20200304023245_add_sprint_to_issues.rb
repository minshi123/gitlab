# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSprintToIssues < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      # index will be added in another migration with `add_concurrent_index`
      add_column :issues, :sprint_id, :bigint
    end
  end

  def down
    with_lock_retries do
      remove_column :issues, :sprint_id
    end
  end
end
