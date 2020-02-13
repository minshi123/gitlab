# frozen_string_literal: true

class AddIndexesToPackageFile < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_concurrent_index :packages_packages, :verification_failure, where: "(verification_failure IS NOT NULL)", name: "packages_packages_verification_failure_partial"
  end

  def down
    remove_concurrent_index :packages_packages, :verification_failure
  end
end
