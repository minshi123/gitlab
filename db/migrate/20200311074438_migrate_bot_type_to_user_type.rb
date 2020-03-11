# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class MigrateBotTypeToUserType < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    execute('UPDATE users SET user_type = bot_type WHERE bot_type IS NOT NULL')
  end

  def down
    execute('UPDATE users SET user_type = NULL WHERE bot_type IS NOT NULL AND bot_type = user_type')
  end
end
