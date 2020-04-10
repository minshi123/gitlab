# frozen_string_literal: true

class AddCommentDetailToServices < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    add_column :services, :comment_detail, :smallint, allow_null: true
  end

  def down
    remove_column :services, :comment_detail
  end
end
