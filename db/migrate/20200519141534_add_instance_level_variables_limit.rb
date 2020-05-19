# frozen_string_literal: true

class AddInstanceLevelVariablesLimit < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    add_column(:plan_limits, :ci_instance_level_variables, :integer, default: 25, null: false)

    create_or_update_plan_limit('ci_instance_level_variables', 'default', 25)
    create_or_update_plan_limit('ci_instance_level_variables', 'free', 25)
    create_or_update_plan_limit('ci_instance_level_variables', 'bronze', 25)
    create_or_update_plan_limit('ci_instance_level_variables', 'silver', 25)
    create_or_update_plan_limit('ci_instance_level_variables', 'gold', 25)
  end

  def down
    create_or_update_plan_limit('ci_instance_level_variables', 'default', 0)
    create_or_update_plan_limit('ci_instance_level_variables', 'free', 0)
    create_or_update_plan_limit('ci_instance_level_variables', 'bronze', 0)
    create_or_update_plan_limit('ci_instance_level_variables', 'silver', 0)
    create_or_update_plan_limit('ci_instance_level_variables', 'gold', 0)

    remove_column(:plan_limits, :ci_instance_level_variables, :integer, default: 25, null: false)
  end
end
