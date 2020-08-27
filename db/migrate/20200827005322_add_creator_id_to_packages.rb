# frozen_string_literal: true

class AddCreatorIdToPackages < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column(:packages_packages, :creator_id, :integer)
    add_index :packages_packages, :creator_id
  end
end
