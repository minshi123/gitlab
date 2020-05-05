# frozen_string_literal: true

class AddRegistrySettingsToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    # rubocop:disable Migration/AddLimitToTextColumns
    add_column :application_settings, :container_registry_vendor, :text
    add_column :application_settings, :container_registry_version, :text
    add_column :application_settings, :container_registry_features, :text, array: true
    # rubocop:enable Migration/AddLimitToTextColumns
  end

  def down
    remove_column :application_settings, :container_registry_vendor
    remove_column :application_settings, :container_registry_version
    remove_column :application_settings, :container_registry_features
  end
end
