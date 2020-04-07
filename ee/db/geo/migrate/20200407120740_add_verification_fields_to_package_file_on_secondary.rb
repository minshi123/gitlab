# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddVerificationFieldsToPackageFileOnSecondary < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :package_file_registry, :verification_failure, :string
    add_column :package_file_registry, :verification_checksum_sha, :binary
    add_column :package_file_registry, :checksum_mismatch, :boolean
    add_column :package_file_registry, :verification_checksum_mismatched, :boolean
    add_column :package_file_registry, :verification_retry_count, :integer
    add_column :package_file_registry, :verified_at, :datetime_with_timezone
    add_column :package_file_registry, :verification_retry_at, :datetime_with_timezone
  end
end
