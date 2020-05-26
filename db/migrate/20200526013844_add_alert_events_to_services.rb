# frozen_string_literal: true

class AddAlertEventsToServices < ActiveRecord::Migration[6.0]
 include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :services, :alert_events, :boolean
    change_column_default :services, :alert_events, true
  end

  def down
    remove_column :services, :alerts_events
  end
end
