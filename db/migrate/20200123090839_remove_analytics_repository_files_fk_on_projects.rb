# frozen_string_literal: true

class RemoveAnalyticsRepositoryFilesFkOnProjects < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      remove_foreign_key :analytics_repository_files, :projects
    end
  end

  def down
    with_lock_retries do
      add_foreign_key :analytics_repository_files, :projects, on_delete: :cascade # rubocop:disable Migration/AddConcurrentForeignKey
    end
  end
end
