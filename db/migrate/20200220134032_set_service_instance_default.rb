# frozen_string_literal: true

class SetServiceInstanceDefault < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_column_default(:services, :instance, from: nil, to: false)
  end
end
