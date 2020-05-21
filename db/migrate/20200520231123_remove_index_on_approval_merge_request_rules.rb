# frozen_string_literal: true

class RemoveIndexOnApprovalMergeRequestRules < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  INDEX_NAME = "approval_rule_name_index_for_code_owners"

  def up
    remove_concurrent_index_by_name :approval_merge_request_rules, INDEX_NAME
  end

  def down
    add_concurrent_index(
      :approval_merge_request_rules,
      [:merge_request_id, :code_owner, :name],
      unique: true,
      where: "(code_owner = true)",
      name: INDEX_NAME
    )
  end
end
