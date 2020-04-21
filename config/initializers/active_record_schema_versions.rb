# frozen_string_literal: true

# Patch to use write version information as empty files under the db/schema_migrations directory
# This is intended to reduce potential for merge conflicts in db/structure.sql
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.prepend(Gitlab::Database::PostgresqlAdapter::SchemaVersionsHandlerMixin)
