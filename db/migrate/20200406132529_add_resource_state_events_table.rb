# frozen_string_literal: true

class AddResourceStateEventsTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    create_table :resource_state_events, id: :bigserial do |t|
      t.references :user, null: false, foreign_key: { on_delete: :nullify },
                   index: { name: 'index_resource_state_events_on_user_id' }
      t.references :issue, null: true, foreign_key: { on_delete: :cascade },
                   index: { name: 'index_resource_state_events_on_issue_id' }
      t.references :merge_request, null: true, foreign_key: { on_delete: :cascade },
                   index: { name: 'index_resource_state_events_on_merge_request_id' }

      t.integer :state, limit: 2, null: false
      t.datetime_with_timezone :created_at, null: false

      t.index :created_at
    end
  end
end
