# frozen_string_literal: true

module Gitlab
  module Database
    module PartitioningMigrationHelpers
      module TableManagementHelpers
        include SchemaHelpers

        def partition_table_by_date(table_name, column_name, min_time:, max_time:)
          primary_key = connection.primary_key(table_name)
          raise "primary key not defined for #{table_name}" if primary_key.nil?

          column_def = find_column_definition(table_name, column_name)
          raise "partition column #{column_name} does not exist on #{table_name}" if column_def.nil?

          partitioned_table_name = "#{table_name}_part"
          create_range_partitioned_copy(partitioned_table_name, table_name, column_def, primary_key)
          create_range_partitions(partitioned_table_name, column_def.name, min_time, max_time)
        end

        def cleanup_partitioned_table(table)
          drop_table("#{table}_part")
        end

        private

        def find_column_definition(table, column)
          connection.columns(table).find { |c| c.name == column.to_s }
        end

        def create_range_partitioned_copy(table_name, template_table_name, partition_column, primary_key)
          tmp_column_name = "#{partition_column.name}_part"

          execute(<<~SQL)
            CREATE TABLE #{table_name} (
              LIKE #{template_table_name} INCLUDING ALL EXCLUDING INDEXES,
              #{tmp_column_name} #{partition_column.sql_type} NOT NULL,
              PRIMARY KEY (#{[primary_key, tmp_column_name].join(", ")})
            ) PARTITION BY RANGE (#{tmp_column_name})
          SQL

          remove_column(table_name, partition_column.name)
          rename_column(table_name, tmp_column_name, partition_column.name)
        end

        def create_range_partitions(table_name, column_name, min_time, max_time)
          min_date = min_time.beginning_of_month.to_date
          max_date = max_time.next_month.beginning_of_month.to_date

          while min_date < max_date
            partition_name = "#{table_name}_#{min_date.strftime('%Y%m%d')}"
            next_date = min_date.next_month

            execute(<<~SQL)
              CREATE TABLE #{partition_name} PARTITION OF #{table_name}
              FOR VALUES FROM ('#{min_date.strftime('%Y-%m-%d')}') TO ('#{next_date.strftime('%Y-%m-%d')}')
            SQL

            min_date = next_date
          end
        end
      end
    end
  end
end
