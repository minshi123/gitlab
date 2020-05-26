# frozen_string_literal: true

class UpdateIndexApprovalRuleNameForCodeOwnersRuleType < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  LEGACY_INDEX_NAME = "index_approval_rule_name_for_code_owners_rule_type"
  SECTIONAL_INDEX_NAME = "index_approval_rule_name_for_sectional_code_owners_rule_type"

  class ApprovalMergeRequestRule < ActiveRecord::Base
    include EachBatch

    enum rule_types: {
      regular: 1,
      code_owner: 2
    }
  end

  def up
    unless index_exists_by_name?(:approval_merge_request_rules, SECTIONAL_INDEX_NAME)
      # Ensure only 1 code_owner rule per merge_request
      #
      add_concurrent_index(
        :approval_merge_request_rules,
        [:merge_request_id, :rule_type, :name, :section],
        unique: true,
        where: "rule_type = #{ApprovalMergeRequestRule.rule_types[:code_owner]}",
        name: SECTIONAL_INDEX_NAME
      )
    end

    if index_exists_by_name?(:approval_merge_request_rules, LEGACY_INDEX_NAME)
      remove_concurrent_index_by_name :approval_merge_request_rules, LEGACY_INDEX_NAME
    end
  end

  def down
    unless index_exists_by_name?(:approval_merge_request_rules, LEGACY_INDEX_NAME)
      # Reconstruct original "legacy" index, but without the unique constraint;
      #   in a rollback situation, we can't guarantee that there will not be
      #   records that were allowed under the more specific SECTIONAL_INDEX_NAME
      #   but would cause uniqueness violations under this one.
      #
      add_concurrent_index(
        :approval_merge_request_rules,
        [:merge_request_id, :rule_type, :name],
        where: "rule_type = #{ApprovalMergeRequestRule.rule_types[:code_owner]}",
        name: LEGACY_INDEX_NAME
      )
    end

    if index_exists_by_name?(:approval_merge_request_rules, SECTIONAL_INDEX_NAME)
      remove_concurrent_index_by_name :approval_merge_request_rules, SECTIONAL_INDEX_NAME
    end
  end
end
