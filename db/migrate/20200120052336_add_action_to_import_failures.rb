# frozen_string_literal: true

class AddActionToImportFailures < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  def change
    add_column :import_failures, :action, :string, limit: 128
  end
end
