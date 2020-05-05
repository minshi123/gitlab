# frozen_string_literal: true

class AddIssuesCreateLimitUsersWhitelistToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  # rubocop:disable Migration/PreventStrings
  def change
    add_column(
      :application_settings,
      :issues_create_limit_users_whitelist,
      :string,
      array: true,
      limit: 255,
      default: []
    )
  end
  # rubocop:enable Migration/PreventStrings
end
