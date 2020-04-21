# frozen_string_literal: true

module Gitlab
  module Database
    class SchemaVersionFiles
      SCHEMA_DIRECTORY = "db/schema_migrations"

      def touch_all(versions)
        FileUtils.rm_rf(schema_directory)
        FileUtils.mkdir_p(schema_directory)

        versions.each do |version|
          FileUtils.touch(File.join(schema_directory, version))
        end
      end

      def load_all
        version_filenames = Dir.glob("20[0-9][0-9]*", base: schema_directory)
        return if version_filenames.empty?

        values = version_filenames.map { |vf| "('#{connection.quote_string(vf)}')" }
        connection.execute(<<~SQL)
          INSERT INTO schema_migrations (version)
          VALUES #{values.join(",")}
          ON CONFLICT DO NOTHING
        SQL
      end

      def schema_directory
        @schema_directory ||= File.join(Rails.root, SCHEMA_DIRECTORY)
      end

      def connection
        @connection ||= ActiveRecord::Base.connection
      end
    end
  end
end
