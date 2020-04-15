# frozen_string_literal: true

class AddNameRegexKeepToContainerExpirationPolicies < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :container_expiration_policies, :name_regex_keep, :string, limit: 255
  end
end
