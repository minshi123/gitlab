# frozen_string_literal: true

class CreatePartitionedForeignKeys < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    create_table :partitioned_foreign_keys do |t|
      t.boolean :cascade_delete, null: false, default: true
      t.text :to_table, null: false
      t.text :from_table, null: false
      t.text :to_column, null: false
      t.text :from_column, null: false
    end

    add_index :partitioned_foreign_keys, [:to_table, :from_table, :from_column], unique: true,
      name: "index_partitioned_foreign_keys_unique_index"
  end

  def down
    drop_table :partitioned_foreign_keys
  end
end
