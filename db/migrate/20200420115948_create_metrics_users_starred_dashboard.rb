# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateMetricsUsersStarredDashboard < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :metrics_users_starred_dashboards do |t|
      t.references :user, index: false, foreign_key: { on_delete: :cascade }, null: false
      t.references :project, index: false, foreign_key: { on_delete: :cascade }, null: false
      t.timestamps_with_timezone
      t.string :dashboard_path, null: false, limit: 255

      t.index %i(user_id project_id dashboard_path), name: "idx_metrics_users_starred_dashboard_on_user_project_dashboard"
    end
  end
end
