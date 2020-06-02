# frozen_string_literal: true

class AddSquashOptionToProject < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :projects, :squash_option, :integer, default: 0
  end
end
