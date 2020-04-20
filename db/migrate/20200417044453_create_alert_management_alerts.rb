# frozen_string_literal: true

class CreateAlertManagementAlerts < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :alert_management_alerts do |t|
      t.text :title, null: false, limit: 200
      t.text :description, limit: 1000
      t.text :service, limit: 100
      t.text :monitoring_tool, limit: 100
      t.text :host, limit: 100
      t.text :fingerprint, limit: 40

      t.integer :severity, default: 0, null: false, limit: 2
      t.integer :status, default: 0, null: false, limit: 2

      t.jsonb :payload
      t.integer :events, default: 1, null: false
      t.datetime_with_timezone :started_at, null: false
      t.datetime_with_timezone :ended_at

      t.references :issue, foreign_key: true
      t.references :project, null: false, foreign_key: { on_delete: :cascade }
      t.index :title
      t.index :events
      t.index :started_at
      t.index :ended_at
      t.index :severity
      t.index :status
      t.index :fingerprint

      t.timestamps_with_timezone
    end
  end
end
