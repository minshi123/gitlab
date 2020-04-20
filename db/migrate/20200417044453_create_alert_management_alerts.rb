# frozen_string_literal: true

class CreateAlertManagementAlerts < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :alert_management_alerts do |t|
      t.text :title, null: false, index: true
      t.text :description
      t.text :service
      t.text :monitoring_tool
      t.text :hosts
      t.binary :fingerprint

      t.integer :severity, default: 0, null: false, limit: 2, index: true
      t.integer :status, default: 0, null: false, limit: 2, index: true

      t.datetime_with_timezone :started_at, null: false, index: true
      t.datetime_with_timezone :ended_at, index: true
      t.integer :events, default: 1, null: false, index: true
      t.integer :iid, null: false
      t.jsonb :payload

      t.references :issue, foreign_key: true
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.index %w(project_id iid), name: 'index_alert_management_alerts_on_project_id_and_iid', where: 'project_id IS NOT NULL', unique: true, using: :btree

      t.timestamps_with_timezone
    end

    add_text_limit :alert_management_alerts, :title, 200
    add_text_limit :alert_management_alerts, :description, 1000
    add_text_limit :alert_management_alerts, :service, 100
    add_text_limit :alert_management_alerts, :monitoring_tool, 100
    add_text_limit :alert_management_alerts, :hosts, 255
  end

  def down
    drop_table :alert_management_alerts
  end
end
