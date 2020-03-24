# frozen_string_literal: true

class AddIndexOnProiectIdToActiveServicesTable < ActiveRecord::Migration[6.0]

  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  INDEX_NAME = 'index_active_services_on_project_id'

  disable_ddl_transaction!

  def up
    add_concurrent_index :services, :project_id, where: '"services"."active" = TRUE'
  end

  def down
    remove_concurrent_index_by_name :services, INDEX_NAME
  end
end
