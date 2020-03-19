# frozen_string_literal: true

# See https://docs.gitlab.com/ee/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class CreateMetricsDashboardAnnotations < ActiveRecord::Migration[6.0]
  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  def change
    create_table :metrics_dashboard_annotations do |t|
      t.datetime_with_timezone :from, null: false
      t.datetime_with_timezone :to
      t.references :environment, index: false, foreign_key: { on_delete: :cascade }, null: true
      t.references :cluster, index: false, foreign_key: { on_delete: :cascade }, null: true
      t.string :dashboard_id, null: false, limit: 255
      t.string :panel_id, limit: 255
      t.text :description, null: false, limit: 255

      t.index %i(environment_id dashboard_id from to), name: "index_metrics_dashboard_annotations_on_environment_id_and_3_col"
      t.index %i(cluster_id dashboard_id from to), name: "index_metrics_dashboard_annotations_on_cluster_id_and_3_columns"
    end
  end
end
