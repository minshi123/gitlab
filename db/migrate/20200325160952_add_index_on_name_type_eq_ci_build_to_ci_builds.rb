# frozen_string_literal: true

class AddIndexOnNameTypeEqCiBuildToCiBuilds < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = 'index_ci_builds_on_name_and_type_eq_ci_build'

  def up
    add_concurrent_index :ci_builds, [:name], where: "type = 'Ci::Build'", name: INDEX_NAME
  end

  def down
    remove_concurrent_index :ci_builds, INDEX_NAME
  end
end
