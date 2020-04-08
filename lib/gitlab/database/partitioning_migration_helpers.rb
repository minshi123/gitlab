# frozen_string_literal: true

module Gitlab module Database
    module PartitioningMigrationHelpers

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

      def fk_function_name(table, prefix: 'fk_fn')
        object_name(table, prefix)
      end

      def fk_trigger_name(table, prefix: 'fk_trigger')
        object_name(table, prefix)
      end

      def object_name(table, type)
        identifier = "#{table}_#{type}"
        hashed_identifier = Digest::SHA256.hexdigest(identifier).first(10)

        "#{type}_#{hashed_identifier}"
      end

      private

      def update_foreign_keys(from_table, to_table, column)
        raise 'changes to custom foreign key functions should be run in a transaction' unless transaction_open?

        yield extract_from_column(to_table, column)

        fn_name = fk_function_name(to_table)
        trigger_name = fk_trigger_name(to_table)
        drop_trigger_if_exists(to_table, trigger_name)

        foreign_key_specs = query_foreign_keys(from_table, to_table)
        if foreign_key_specs.empty?
          drop_function_if_exists(fn_name)
        else
          create_or_replace_fk_function(fn_name, foreign_key_specs)
          create_fk_trigger(to_table, trigger_name, fn_name)
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
        query = table.
          project([table[:from_table], table[:from_column], table[:to_column], table[:cascade_delete]]).
          where(table[:to_table].eq(to_table))

        execute(query.to_sql).map(&:symbolize_keys)
      end

      def insert_foreign_key(from_table, to_table, from_column, to_column, cascade_delete)
        table = Arel::Table.new(:partitioned_foreign_keys)
        insert_manager = Arel::InsertManager.new.
          insert([[table[:from_table], from_table],
                   [table[:to_table], to_table],
                   [table[:from_column], from_column],
                   [table[:to_column], to_column],
                   [table[:cascade_delete], cascade_delete]]).
          into(table)

        execute(insert_manager.to_sql)
      end

      def delete_foreign_key(from_table, to_table, from_column)
        table = Arel::Table.new(:partitioned_foreign_keys)
        delete_manager = Arel::DeleteManager.new.
          from(table).
          where(table[:from_table].eq(from_table)).
          where(table[:to_table].eq(to_table)).
          where(table[:from_column].eq(from_column))

        execute(delete_manager.to_sql)
      end

      def drop_trigger_if_exists(table_name, name)
        execute(<<~SQL)
          DROP TRIGGER IF EXISTS #{name} ON #{table_name}
        SQL
      end

      def drop_function_if_exists(name)
        execute(<<~SQL)
          DROP FUNCTION IF EXISTS #{name}
        SQL
      end

      def create_or_replace_fk_function(fn_name, fk_specs)
        cascade_operations = build_cascade_statements(fk_specs)

        execute(<<~SQL)
          CREATE OR REPLACE FUNCTION #{fn_name}()
          RETURNS TRIGGER AS
          $$
          BEGIN
          #{cascade_operations.join("\n")}
          RETURN OLD;
          END
          $$ LANGUAGE PLPGSQL
        SQL
      end

      def build_cascade_statements(fk_specs)
        fk_specs.map do |spec|
          if spec[:cascade_delete]
            "DELETE FROM #{spec[:from_table]} WHERE #{spec[:from_column]} = OLD.#{spec[:to_column]};"
          else
            "UPDATE #{spec[:from_table]} SET #{spec[:from_column]} = NULL WHERE #{spec[:from_column]} = OLD.#{spec[:to_column]};"
          end
        end
      end

      def create_fk_trigger(table_name, trigger_name, fn_name)
        execute(<<~SQL)
          CREATE TRIGGER #{trigger_name}
          AFTER DELETE ON #{table_name}
          FOR EACH ROW
          EXECUTE PROCEDURE #{fn_name}();
        SQL
      end
    end
  end
end
