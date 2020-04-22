# frozen_string_literal: true

class CreateCiInstanceVariables < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    create_table :ci_instance_variables do |t|
      t.text :key, null: false
      t.text :encrypted_value
      t.text :encrypted_value_iv
      t.integer :variable_type, null: false, limit: 2, default: 1
      t.boolean :masked, default: false, allow_null: false
      t.boolean :protected, default: false, allow_null: false
    end

    add_text_limit(:ci_instance_variables, :key, 255)
    add_text_limit(:ci_instance_variables, :encrypted_value, 1024)
    add_text_limit(:ci_instance_variables, :encrypted_value_iv, 255)

    add_index :ci_instance_variables, :key, unique: true
  end

  def down
    remove_concurrent_index :ci_instance_variables, :key

    remove_text_limit(:ci_instance_variables, :encrypted_value_iv)
    remove_text_limit(:ci_instance_variables, :encrypted_value)
    remove_text_limit(:ci_instance_variables, :key)

    drop_table :ci_instance_variables
  end
end
