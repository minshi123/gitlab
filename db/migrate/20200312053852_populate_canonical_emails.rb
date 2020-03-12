# frozen_string_literal: true

class PopulateCanonicalEmails < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  class User < ActiveRecord::Base
    include EachBatch

    self.table_name = 'users'
  end

  # Limited to *@gmail.com addresses only as a first iteration, because we know
  # Gmail ignores `.` appearing in the Agent name, as well as anything after `+`

  def up
    Gitlab::BackgroundMigration.steal('PopulateCanonicalEmails')

    PopulateCanonicalEmails::User
        .where("email LIKE '%gmail.com%'")
        .each_batch(of: 100) do |batch|
      Gitlab::BackgroundMigration::PopulateCanonicalEmails.new.perform(batch)
    end
  end

  def down
    # no-op
  end
end
