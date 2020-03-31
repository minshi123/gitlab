# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class EnableContainerExpirationPoliciesByDefault < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      change_column_default :container_expiration_policies, :enabled, true
    end
  end

  def down
    with_lock_retries do
      change_column_default :container_expiration_policies, :enabled, false
    end
  end
end
