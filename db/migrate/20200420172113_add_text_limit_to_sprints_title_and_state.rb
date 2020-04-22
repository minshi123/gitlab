# frozen_string_literal: true

class AddTextLimitToSprintsTitleAndState < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  TITLE_CONSTRAINT_NAME = 'sprints_title'
  STATE_CONSTRAINT_NAME = 'sprints_state'

  def up
    add_text_limit :sprints, :title, 255, constraint_name: TITLE_CONSTRAINT_NAME
    add_text_limit :sprints, :state, 255, constraint_name: STATE_CONSTRAINT_NAME
  end

  def down
    remove_check_constraint :sprints, TITLE_CONSTRAINT_NAME
    remove_check_constraint :sprints, STATE_CONSTRAINT_NAME
  end
end
