# frozen_string_literal: true

class MigrateIssueMentionsToDb < ActiveRecord::Migration[5.2]
  DOWNTIME = false

  disable_ddl_transaction!

  DELAY = 2.minutes.to_i
  BATCH_SIZE = 10000
  MIGRATION = 'UserMentions::CreateResourceUserMention'

  JOIN = "LEFT JOIN issue_user_mentions ON issues.id = issue_user_mentions.issue_id"
  QUERY_CONDITIONS = "(description like '%@%' OR title like '%@%') AND issue_user_mentions.issue_id IS NULL"

  class Issue < ActiveRecord::Base
    include EachBatch

    self.table_name = 'issues'
  end

  def up
    Issue
      .joins(JOIN)
      .where(QUERY_CONDITIONS)
      .each_batch(of: BATCH_SIZE) do |batch, index|
      range = batch.pluck(Arel.sql('MIN(issues.id)'), Arel.sql('MAX(issues.id)')).first
      BackgroundMigrationWorker.perform_in(index * DELAY, MIGRATION, ['Issue', JOIN, QUERY_CONDITIONS, false, *range])
    end
  end

  def down
    # no-op
  end
end
