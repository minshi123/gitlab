# frozen_string_literal: true

module Gitlab
  module Database
    module PostgresqlAdapter
      module SchemaVersionsHandlerMixin
        extend ActiveSupport::Concern

        def dump_schema_information # :nodoc:
          versions = schema_migration.all_versions
          touch_files(versions) if versions.any?

          nil
        end

        private

        def touch_files(versions)
          Gitlab::Database::SchemaVersionFiles.new.touch_all(versions)
        end
      end
    end
  end
end
