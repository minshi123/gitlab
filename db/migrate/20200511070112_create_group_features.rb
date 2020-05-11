class CreateGroupFeatures < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :group_features do |t|
      t.references :group, foreign_key: { to_table: :namespaces, on_delete: :cascade }, index: { unique: true }, null: false
      t.integer :wiki_access_level, null: false
    end
  end
end
