# frozen_string_literal: true

class AddUsersBioSyncTrigger < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    # Upsert the truncated bio. We only had length validation on the model, so we might have "invalid" entries in the DB.
    execute <<-EOF.strip_heredoc
    CREATE OR REPLACE FUNCTION sync_users_bio_to_user_details() RETURNS TRIGGER AS
    $BODY$
    BEGIN
      INSERT INTO
          user_details (
            user_id,
            bio
          )
          VALUES (
            new.id,
            substring(COALESCE(new.bio, '') from 1 for 255)
          )
      ON CONFLICT (user_id)
        DO UPDATE SET
          "bio" = EXCLUDED."bio";
      RETURN new;
    END;
    $BODY$
    language plpgsql;
    EOF

    execute <<-EOF.strip_heredoc
    CREATE TRIGGER trigger_user_details_bio_sync_on_update
      AFTER UPDATE ON users
      FOR EACH ROW
      WHEN (OLD.bio IS DISTINCT FROM NEW.bio)
      EXECUTE PROCEDURE sync_users_bio_to_user_details();
    EOF

    # When user is created, upsert to user_details only when bio != ''
    execute <<-EOF.strip_heredoc
    CREATE TRIGGER trigger_user_details_bio_sync_on_insert
      AFTER INSERT ON users
      FOR EACH ROW
      WHEN (
        (COALESCE(NEW.bio, '') IS DISTINCT FROM '')
      )
      EXECUTE PROCEDURE sync_users_bio_to_user_details();
    EOF
  end

  def down
    execute 'DROP TRIGGER IF EXISTS trigger_user_details_bio_sync_on_update ON users'
    execute 'DROP TRIGGER IF EXISTS trigger_user_details_bio_sync_on_insert ON users'
    execute 'DROP FUNCTION IF EXISTS sync_users_bio_to_user_details();'
  end
end
