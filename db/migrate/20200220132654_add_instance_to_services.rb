# frozen_string_literal: true

class AddInstanceToServices < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column(:services, :instance, :boolean)
  end
end
