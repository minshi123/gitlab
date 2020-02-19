# frozen_string_literal: true

class AddDropOlderActiveDeploymentsToProjects < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    add_column :projects, :drop_older_active_deployments, :smallint, allow_null: false
  end
end
