# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class AddPackageFileChecksumStateToGeoNodeStatus < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    change_table :geo_node_statuses do |t|
      t.integer :package_files_checksummed_count
      t.integer :package_files_checksum_failed_count
    end
  end
end
