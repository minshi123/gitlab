class CreateProjectSecuritySettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      create_table :project_security_settings do |t|
        t.references :project, index: true, null: false, foreign_key: { on_delete: :cascade }
        t.boolean :auto_fix_container_scanning, default: true
        t.boolean :auto_fix_dast, default: true
        t.boolean :auto_fix_dependency_scanning, default: true
        t.boolean :auto_fix_sast, default: true

        t.timestamps_with_timezone
      end
    end
  end

  def down
    with_lock_retries do
      drop_table :project_security_settings
    end
  end
end
