# frozen_string_literal: true

require "spec_helper"

describe Gitlab::Database::CustomStructure do
  let_it_be(:structure) { described_class.new }
  let(:io) { StringIO.new }

  context "when there are no partitioned_foreign_keys" do
    it "dumps a valid structure file" do
      structure.dump(io)

      expect(io.string).to eq("SET search_path=public;\n\n")
    end
  end

  context "when there are partitioned_foreign_keys" do
    let!(:first_fk) do
      Gitlab::Database::PartitioningMigrationHelpers::PartitionedForeignKey.create(
        cascade_delete: true, to_table: "projects", from_table: "issues", to_column: "id", from_column: "project_id")
    end
    let!(:second_fk) do
      Gitlab::Database::PartitioningMigrationHelpers::PartitionedForeignKey.create(
        cascade_delete: false, to_table: "issues", from_table: "issues", to_column: "id", from_column: "moved_to_id")
    end

    it "dumps a file with the command to restore the keys" do
      structure.dump(io)

      expect(io.string).to eq(<<~DATA)
        SET search_path=public;

        COPY partitioned_foreign_keys (id, cascade_delete, to_table, from_table, to_column, from_column) FROM STDIN;
        #{first_fk.id}\ttrue\tprojects\tissues\tid\tproject_id
        #{second_fk.id}\tfalse\tissues\tissues\tid\tmoved_to_id
        \\.
      DATA
    end
  end
end
