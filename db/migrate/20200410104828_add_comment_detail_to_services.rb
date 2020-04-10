# frozen_string_literal: true

class AddCommentDetailToServices < ActiveRecord::Migration[6.0]
  # Uncomment the following include if you require helper functions:
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  DEFAULT_COMMENT_DETAIL = 1

  disable_ddl_transaction!

  def up
    add_column_with_default :services, :comment_detail, :smallint, default: DEFAULT_COMMENT_DETAIL
  end

  def down
    remove_column :services, :comment_detail
  end
end
