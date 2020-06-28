# frozen_string_literal: true

class AddMaintenanceModeApplicationToSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_table :application_settings do |t|
      t.boolean :maintenance_mode, default: false
      t.text :maintenance_mode_message
    end
  end
end
