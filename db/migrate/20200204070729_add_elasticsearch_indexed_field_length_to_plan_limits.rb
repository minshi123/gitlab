# frozen_string_literal: true

class AddElasticsearchIndexedFieldLengthToPlanLimits < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def change
    add_column :plan_limits, :elasticsearch_indexed_field_length, :integer, null: false, default: 0
  end
end
