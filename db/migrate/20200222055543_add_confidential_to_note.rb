# frozen_string_literal: true
class AddConfidentialToNote < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :notes, :confidential, :boolean, default: false
  end
end
