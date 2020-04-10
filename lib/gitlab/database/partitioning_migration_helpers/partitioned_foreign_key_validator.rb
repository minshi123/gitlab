# frozen_string_literal: true

module Gitlab
  module Database
    module PartitioningMigrationHelpers
      class PartitionedForeignKeyValidator < ActiveModel::Validator
        def validate(record)
          validate_table_exists(record, :to_table)
          validate_table_exists(record, :from_table)
          validate_column_exists(record, :to_table, :to_column)
          validate_column_exists(record, :from_table, :from_column)
        end

        private

        def validate_table_exists(record, table_field)
          unless table_exists?(record[table_field])
            record.errors.add(table_field, "must be a valid table")
          end
        end

        def validate_column_exists(record, table_field, column_field)
          unless column_exists?(record[table_field], record[column_field])
            record.errors.add(column_field, "must be a valid column")
          end
        end

        def table_exists?(table_name)
          return false if table_name.blank?

          connection.execute(<<~SQL).first&.fetch("count", 0)&.positive?
            SELECT COUNT(*) AS count
            FROM information_schema.tables
            WHERE table_catalog = '#{connection.current_database}'
            AND table_schema = 'public'
            AND table_type = 'BASE TABLE'
            AND table_name = '#{table_name}'
          SQL
        end

        def column_exists?(table_name, column_name)
          return false if table_name.blank? || column_name.blank?

          connection.execute(<<~SQL).first&.fetch("count", 0)&.positive?
            SELECT COUNT(*) AS count
            FROM information_schema.columns
            WHERE table_catalog = '#{connection.current_database}'
            AND table_schema = 'public'
            AND table_name = '#{table_name}'
            AND column_name = '#{column_name}'
          SQL
        end

        def connection
          ActiveRecord::Base.connection
        end
      end
    end
  end
end
