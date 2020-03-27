# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::JSON::StreamingSerializer do
  let_it_be(:user) { create(:user) }
  let_it_be(:release) { create(:release) }
  let_it_be(:group) { create(:group) }
  let_it_be(:exportable) do
    create(:project,
      :public,
      :repository,
      :issues_disabled,
      :wiki_enabled,
      :builds_private,
      description: 'description',
      releases: [release],
      group: group,
      approvals_before_merge: 1)
  end
  let_it_be(:issue) { create(:issue, assignees: [user], project: exportable) }

  let(:exportable_path) { "project" }
  let(:hash) { { name: exportable.name, description: exportable.description }.stringify_keys }
  let(:json_writer) { instance_double('Gitlab::ImportExport::JSON::LegacyWriter') }
  let(:relations_schema) do
    {
      only: [:name, :description],
      include: include,
      preload: { issues: nil }
    }
  end
  let(:include) { [] }

  subject do
    described_class.new(exportable, relations_schema, json_writer, exportable_path: exportable_path)
  end

  before do
    allow(json_writer).to receive(:write_attributes).with(exportable_path, hash)
    allow(json_writer).to receive(:write_relation).with(exportable_path, :group, anything)
  end

  describe '#execute' do
    it "calls json_writer.write_attributes with proper params" do
      expect(json_writer).to receive(:write_attributes).with(exportable_path, hash)

      subject.execute
    end

    context 'with many relations' do
      let(:include) do
        [{
          issues:
            {
              include: []
            }
        }]
      end

      before do
        allow(json_writer).to receive(:write_relation_array).with(exportable_path, :issues, array_including(issue.to_json))
      end

      it "calls json_writer.write_relation_array with proper params" do
        expect(json_writer).to receive(:write_relation_array).with(exportable_path, :issues, array_including(issue.to_json))

        subject.execute
      end
    end

    context 'with single relation' do
      let(:include) do
        [{
           group:
             {
               include: []
             }
         }]
      end

      before do
        allow(json_writer).to receive(:write_relation).with(exportable_path, :group, group.to_json)
      end

      it "calls json_writer.write_relation with proper params" do
        expect(json_writer).to receive(:write_relation).with(exportable_path, :group, group.to_json)

        subject.execute
      end
    end

    context 'with array relation' do
      let(:project_member) { create(:project_member, user: user) }
      let(:include) do
        [{
           project_members:
             {
               include: []
             }
         }]
      end

      before do
        allow(exportable).to receive(:project_members).and_return([project_member])
        allow(json_writer).to receive(:write_relation_array).with(exportable_path, :project_members, array_including(project_member.to_json))
      end

      it "calls json_writer.write_relation_array with proper params" do
        expect(json_writer).to receive(:write_relation_array).with(exportable_path, :project_members, array_including(project_member.to_json))

        subject.execute
      end
    end
  end
end
