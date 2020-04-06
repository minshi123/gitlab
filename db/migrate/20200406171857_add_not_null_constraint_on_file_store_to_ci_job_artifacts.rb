# frozen_string_literal: true

class AddNotNullConstraintOnFileStoreToCiJobArtifacts < ActiveRecord::Migration[6.0]
  CONSTRAINT_NAME = 'file_store_not_null'
  DOWNTIME = false

  def up
    execute <<~SQL
      ALTER TABLE ci_job_artifacts ADD CONSTRAINT #{CONSTRAINT_NAME} CHECK (file_store IS NOT NULL) NOT VALID;
    SQL
  end

  def down
    execute <<~SQL
      ALTER TABLE ci_job_artifacts DROP CONSTRAINT IF EXISTS #{CONSTRAINT_NAME};
    SQL
  end
end
