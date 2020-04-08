# frozen_string_literal: true

module Gitlab
  module Database
    module PartitioningMigrationHelpers
      include SchemaHelpers

      def add_foreign_key(from_table, to_table, column: nil, primary_key: :id, on_delete: :cascade)
        update_foreign_keys(from_table, to_table, column) do |from_column|
          cascade_delete = extract_cascade_option(on_delete)
          insert_foreign_key(from_table, to_table, from_column, primary_key, cascade_delete)
        end
      end

      def remove_foreign_key(from_table, to_table, column: nil)
        update_foreign_keys(from_table, to_table, column) do |from_column|
          delete_foreign_key(from_table, to_table, from_column)
        end
      end

      def fk_function_name(table)
        object_name(table, "fk_cascade_function")
      end

      def fk_trigger_name(table)
        object_name(table, "fk_cascade_trigger")
      end

      private

      def update_foreign_keys(from_table, to_table, column)
        raise "changes to custom foreign key functions should be run in a transaction" unless transaction_open?

        yield extract_from_column(to_table, column)

        fn_name = fk_function_name(to_table)
        trigger_name = fk_trigger_name(to_table)
        drop_trigger(to_table, trigger_name, if_exists: true)

        foreign_key_specs = query_foreign_keys(from_table, to_table)
        if foreign_key_specs.empty?
          drop_function(fn_name, if_exists: true)
        else
          create_or_replace_fk_function(fn_name, foreign_key_specs)
          create_function_trigger(trigger_name, fn_name, fires: "AFTER DELETE ON #{to_table}")
        end
      end

      def extract_from_column(to_table, column)
        column || "#{to_table.to_s.singularize}_id"
      end

      def extract_cascade_option(on_delete)
        case on_delete
        when :cascade then true
        when :nullify then false
        else raise ArgumentError, "invalid option #{on_delete} for :on_delete"
        end
      end

      def query_foreign_keys(from_table, to_table)
        table = Arel::Table.new(:partitioned_foreign_keys)
        query = table
          .project([table[:from_table], table[:from_column], table[:to_column], table[:cascade_delete]])
          .where(table[:to_table].eq(to_table))

        execute(query.to_sql).map(&:symbolize_keys)
      end

      def insert_foreign_key(from_table, to_table, from_column, to_column, cascade_delete)
        table = Arel::Table.new(:partitioned_foreign_keys)
        insert_manager = Arel::InsertManager.new
          .insert([[table[:from_table], from_table],
                   [table[:to_table], to_table],
                   [table[:from_column], from_column],
                   [table[:to_column], to_column],
                   [table[:cascade_delete], cascade_delete]])
          .into(table)

        execute(insert_manager.to_sql)
      end

      def delete_foreign_key(from_table, to_table, from_column)
        table = Arel::Table.new(:partitioned_foreign_keys)
        delete_manager = Arel::DeleteManager.new
          .from(table)
          .where(table[:from_table].eq(from_table))
          .where(table[:to_table].eq(to_table))
          .where(table[:from_column].eq(from_column))

        execute(delete_manager.to_sql)
      end

      def create_or_replace_fk_function(fn_name, fk_specs)
        create_trigger_function(fn_name, replace: true) do
          cascade_statements = build_cascade_statements(fk_specs)
          cascade_statements << "RETURN OLD;"

          cascade_statements.join("\n")
        end
      end

      def build_cascade_statements(fk_specs)
        fk_specs.map do |spec|
          from_table, from_column, to_column = spec.values_at(:from_table, :from_column, :to_column)

          if spec[:cascade_delete]
            "DELETE FROM #{from_table} WHERE #{from_column} = OLD.#{to_column};"
          else
            "UPDATE #{from_table} SET #{from_column} = NULL WHERE #{from_column} = OLD.#{to_column};"
          end
        end
      end
    end
  end
end
