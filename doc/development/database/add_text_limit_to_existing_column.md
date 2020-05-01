# Adding a text limit constraint to an existing column

Adding a text limit to an existing database column requires database structure changes and potential data changes. In case the table is in use, we should always assume that there is inconsistent data.

To add a text limit constraint to an existing column:

1. Release `N.M` - Add limit to the column (without validation) using a regular migration.

   This adds the constraint to the column, so **new** entries (inserts/updates) are validated against the limit.

   It does not validate existing records as there may be invalid values with a length greater than the new limit.

1. Release `N.M` - Add a data migration to fix or clean up existing records (i.e. ones with a length greater than the new limit).

   If the table is large and / or the migration requires a lot of updates, a background migration is required. Otherwise, a regular (post) migration should suffice.

1. Release `N.M` - Add an issue for the milestone of release `N.M+1` to validate the text limit

1. Release `N.M+1` - Validate the text limit with a migration in the next release.

Edge case:

If you have to clean up a text column for a really large table (e.g. the `artifacts` in `ci_builds`), your background migration will go on for a while and it will need an additional [background migration cleaning up](https://docs.gitlab.com/ee/development/background_migrations.html#cleaning-up) in the release after adding the data migration. In that rare case you will need 3 releases end to end:
1. Release `N.M` - Add limit and run background migration
1. Release `N.M+1` - Cleanup the background migration
1. Release `N.M+2` - Validate the text limit


## Example

Let's assume that we want to add a 1024 character limit to the title (`title_html`) of `issues`.

Issues is a pretty busy, large table with more than 25 million rows, so we don't want to lock all other processes that try to access it while running the update.

Also, after checking our production database, we know that there are ~100 `issues` with more characters in their title than the 1024 character limit, so we can not add and validate the constraint in one step.

**Note**: *Even if we did not have any record with a title larger than the provided limit, another instance of GitLab could have such records, so we would follow the same process either way*.

### Prevent new invalid records

We first add the limit as a `NOT VALID` check constraint to the table, which enforces consistency when new records are inserted or current records are updated.

In the example above, the existing issues with more than 1024 characters in their title will not be affected and you'll be still able to update records in the `issues` table. However, when you'd try to update the `title_html` with a title that has more than 1024 characters, the constraint causes a database error.

Migration file for adding the non validated text limit constraint:

**db/migrate/20200501000001_add_text_limit_migration.rb**
```ruby
class AddTextLimitMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    # This will add the constraint WITHOUT validating it
    add_text_limit :issues, :title_html, 1024, validate: false
  end

  def down
    # Down is required as `add_text_limit` is not reversible
    remove_text_limit :issues, :title_html
  end
end
```

#### Data migration to fix existing records

The approach here depends on the data volume and the cleanup strategy. The number of records that must be fixed on GitLab.com is a nice indicator that will help us decide whether to use a regular, post or a background data migration. If we can easily find "invalid" records by doing a simple database query and the record count is not that high, then the data migration can be executed within a Rails migration.

In case the data volume is higher (>1000 records), it's better to create a background migration. If unsure, please contact the database team for advice.

In this example we choose to run a normal post migration as we should be able to comfortably update the offending records in the 10 minutes that is [the maximum recommended time for post migrations](https://docs.gitlab.com/ee/development/database_review.html#timing-guidelines-for-migrations).

Example for cleaning up records in the `issues` table within a database migration:

**db/post_migrate/20200501000002_cap_title_length_on_issues.rb**
```ruby
class CapTitleLengthOnIssues < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false
  BATCH_SIZE = 500 # conservative approach as this is a busy table and we are not expecting many invalid records

  disable_ddl_transaction!

  class Issue < ActiveRecord::Base
    include EachBatch
  end

  def up
    # processing in batches as there may be instances with way more invalid issues
    update_value = Arel.sql('substring(title_html from 1 for 1024)')

    update_column_in_batches(:issues, :title_html, update_value) do |table, query|
      query.where('char_length(title_html) > 1024')
    end
  end

  def down
    # no-op : the part of the title_html after the limit is lost forever
  end
end
```

### Validate the text limit

Validating the text limit will scan the whole table and make sure that each record is correct.

The following migration is one month after the previous two, and will run with the next release of GitLab:

**db/migrate/20200601000001_validate_text_limit_migration.rb**
```ruby
class ValidateTextLimitMigration < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    if check_text_limit_exists?(:issues, :title_html)
      validate_text_limit :issues, :title_html
    end
  end

  def down
    # no-op
  end
end
```
