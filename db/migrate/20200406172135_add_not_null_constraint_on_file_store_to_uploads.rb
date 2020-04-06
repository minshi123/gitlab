# frozen_string_literal: true

class AddNotNullConstraintOnFileStoreToUploads < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = 'store_not_null'
  DOWNTIME = false

  def up
    execute <<~SQL
      ALTER TABLE uploads ADD CONSTRAINT #{CONSTRAINT_NAME} CHECK (store IS NOT NULL) NOT VALID;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE uploads DROP CONSTRAINT IF EXISTS #{CONSTRAINT_NAME};
    SQL
  end
end
