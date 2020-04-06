# frozen_string_literal: true

class AddNotNullConstraintOnFileStoreToLfsObjects < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = 'file_store_not_null'
  DOWNTIME = false

  def up
    execute <<~SQL
      ALTER TABLE lfs_objects ADD CONSTRAINT #{CONSTRAINT_NAME} CHECK (file_store IS NOT NULL) NOT VALID;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE lfs_objects DROP CONSTRAINT IF EXISTS #{CONSTRAINT_NAME};
    SQL
  end
end
