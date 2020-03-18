# frozen_string_literal: true

class CreatePypiPackageMetadata < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    create_table :packages_pypi_metadata do |t|
      t.references :package, index: { unique: true }, null: false, foreign_key: { to_table: :packages_packages, on_delete: :cascade }, type: :bigint
      t.string "required_python", null: false, limit: 255
    end
  end
end
