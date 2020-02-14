# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateEnvironmentForSelfMonitoringProject < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    return unless self_monitoring_project_id = Gitlab::CurrentSettings.self_monitoring_project_id

    execute <<~SQL
      INSERT INTO environments (project_id, name, slug, created_at, updated_at)
      SELECT #{self_monitoring_project_id}, 'production', 'production', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      WHERE NOT EXISTS (
        SELECT id
        FROM environments
        WHERE environments.project_id = #{self_monitoring_project_id}
      )
    SQL
  end

  def down; end
end
