# frozen_string_literal: true

class AddSpamCheckEndpointToApplicationSettings < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :application_settings, :spam_check_endpoint, :string
  end
end
