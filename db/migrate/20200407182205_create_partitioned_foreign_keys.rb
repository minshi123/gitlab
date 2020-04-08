# frozen_string_literal: true

class CreatePartitionedForeignKeys < ActiveRecord::Migration[6.0]
  include Gitlab::Database::PartitioningMigrationHelpers

  DOWNTIME = false

  def up
    create_table :partitioned_foreign_keys, id: false do |t|
      t.boolean :cascade_delete, null: false, default: true
      t.text :to_table, null: false
      t.text :from_table, null: false
      t.text :from_column, null: false
      t.text :to_column, null: false
    end

    execute(<<~SQL)
      ALTER TABLE partitioned_foreign_keys ADD CONSTRAINT partitioned_foreign_keys_pkey
      PRIMARY KEY (to_table, from_table, from_column)
    SQL
  end

  def down
    drop_table :partitioned_foreign_keys
  end
end
