# frozen_string_literal: true

class AddProjectIdToSentryIssues < ActiveRecord::Migration[5.2]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :sentry_issues, :project_id, :integer
    add_concurrent_foreign_key :sentry_issues, :projects, column: :project_id, on_delete: :cascade
    add_timestamps_with_timezone :sentry_issues, null: true

    execute <<-SQL
      UPDATE sentry_issues
      SET project_id = issues.project_id
      FROM issues
      WHERE sentry_issues.issue_id = issues.id
    SQL
  end

  def down
    remove_foreign_key :sentry_issues, :projects
    remove_column :sentry_issues, :project_id
    remove_timestamps :sentry_issues, null: true
  end
end
