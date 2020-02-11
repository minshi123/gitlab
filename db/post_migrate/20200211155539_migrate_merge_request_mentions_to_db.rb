# frozen_string_literal: true

class MigrateMergeRequestMentionsToDb < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  disable_ddl_transaction!

  DELAY = 2.minutes.to_i
  BATCH_SIZE = 10000
  MIGRATION = 'UserMentions::CreateResourceUserMention'

  JOIN = "LEFT JOIN merge_request_user_mentions on merge_requests.id = merge_request_user_mentions.merge_request_id"
  QUERY_CONDITIONS = "(description like '%@%' OR title like '%@%') AND merge_request_user_mentions.merge_request_id IS NULL"

  class MergeRequest < ActiveRecord::Base
    include EachBatch

    self.table_name = 'merge_requests'
  end

  class MergeRequestUserMention < ActiveRecord::Base
    include EachBatch

    self.table_name = 'merge_request_user_mentions'
  end

  def up
    # cleanup design user mentions with no actual mentions,
    # re https://gitlab.com/gitlab-org/gitlab/-/merge_requests/24586#note_285982468
    MergeRequestUserMention
      .where(mentioned_users_ids: nil)
      .where(mentioned_groups_ids: nil)
      .where(mentioned_projects_ids: nil).each_batch(of: BATCH_SIZE) do |batch|
      batch.delete_all
    end

    MergeRequest
      .joins(JOIN)
      .where(QUERY_CONDITIONS)
      .each_batch(of: BATCH_SIZE) do |batch, index|
      range = batch.pluck(Arel.sql('MIN(merge_requests.id)'), Arel.sql('MAX(merge_requests.id)')).first
      BackgroundMigrationWorker.perform_in(index * DELAY, MIGRATION, ['MergeRequest', JOIN, QUERY_CONDITIONS, false, *range])
    end
  end

  def down
    # no-op
  end
end
