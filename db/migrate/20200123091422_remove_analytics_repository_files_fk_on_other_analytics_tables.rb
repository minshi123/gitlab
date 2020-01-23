# frozen_string_literal: true

class RemoveAnalyticsRepositoryFilesFkOnOtherAnalyticsTables < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_foreign_key :analytics_repository_file_edits, :analytics_repository_files
      remove_foreign_key :analytics_repository_file_commits, :analytics_repository_files
    end
  end

  def down
    with_lock_retries do
      add_foreign_key :analytics_repository_file_edits, :analytics_repository_files, on_delete: :cascade # rubocop:disable Migration/AddConcurrentForeignKey
      add_foreign_key :analytics_repository_file_commits, :analytics_repository_files, on_delete: :cascade # rubocop:disable Migration/AddConcurrentForeignKey
    end
  end
end
