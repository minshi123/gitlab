# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddSprintsForeignKeyToGroups < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_foreign_key :sprints, :namespaces, column: :group_id, on_delete: :cascade
  end

  def down
    remove_foreign_key :sprints, column: :group_id
  end
end
