class AddElasticsearchPauseIndexingToApplicationSettings < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  disable_ddl_transaction!

  def up
    add_column_with_default :application_settings, :elasticsearch_pause_indexing, :boolean, default: false
  end

  def down
    remove_column :application_settings, :elasticsearch_pause_indexing
  end
end
