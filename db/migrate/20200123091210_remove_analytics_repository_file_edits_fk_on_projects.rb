# frozen_string_literal: true

class RemoveAnalyticsRepositoryFileEditsFkOnProjects < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_foreign_key :analytics_repository_file_edits, :projects
    end
  end

  def down
    with_lock_retries do
      add_foreign_key :analytics_repository_file_edits, :projects, on_delete: :cascade
    end
  end
end
