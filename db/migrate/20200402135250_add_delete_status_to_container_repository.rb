# frozen_string_literal: true

class AddDeleteStatusToContainerRepository < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column(:container_repositories,
               :delete_status,
               :string,
               allow_null: true,
               limit: 255)
  end

  def down
    remove_column(:container_repositories,
                  :delete_status)
  end
end
