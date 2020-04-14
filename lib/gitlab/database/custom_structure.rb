# frozen_string_literal: true

module Gitlab
  module Database
    class CustomStructure
      def dump(io)
        io << "SET search_path=public;\n\n"

        dump_partitioned_foreign_keys(io) if foreign_keys_exist?
      end

      private

      def dump_partitioned_foreign_keys(io)
        io << "COPY partitioned_foreign_keys (#{foreign_key_columns.join(", ")}) FROM STDIN;\n"

        PartitioningMigrationHelpers::PartitionedForeignKey.find_each do |fk|
          io << fk.attributes.values_at(*foreign_key_columns).join("\t") << "\n"
        end
        io << "\\.\n"
      end

      def foreign_keys_exist?
        PartitioningMigrationHelpers::PartitionedForeignKey.exists?
      end

      def foreign_key_columns
        @foreign_key_columns ||= PartitioningMigrationHelpers::PartitionedForeignKey.column_names
      end
    end
  end
end
