# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::JSON::LegacyReader do
  let(:fixture) { 'spec/fixtures/lib/gitlab/import_export/light/project.json' }
  let(:project_tree) { JSON.parse(File.read(fixture)) }
  let(:legacy_reader) { described_class.new(path) }

  describe '#valid?' do
    subject { legacy_reader.valid? }

    context 'given valid path' do
      let(:path) { fixture }

      it { is_expected.to be true }
    end

    context 'given invalid path' do
      let(:path) { 'spec/non-existing-folder/do-not-create-this-file.json' }

      it { is_expected.to be false }
    end
  end

  describe '#root_attributes' do
    let(:excluded_attributes) { %w[milestones labels issues services snippets] }
    let(:path) { fixture }

    subject { legacy_reader.root_attributes(excluded_attributes) }

    it 'returns hash without excluded attributes' do
      expect(subject).to eq({
        "description" => "Nisi et repellendus ut enim quo accusamus vel magnam.",
        "import_type" => "gitlab_project",
        "creator_id" => 123,
        "visibility_level" => 10,
        "archived" => false,
        "hooks" => []
      })
    end

    it 'returns hash exclude excluded_attributes and consumed_relations' do
      legacy_reader.consume_relation('import_type')
      legacy_reader.consume_relation('archived')

      expect(subject).to eq({
        "description" => "Nisi et repellendus ut enim quo accusamus vel magnam.",
        "creator_id" => 123,
        "visibility_level" => 10,
        "hooks" => []
      })
    end
  end

  describe '#consume_relation' do
    let(:path) { fixture }
    let(:key) { 'description' }

    context 'key has been consumed' do
      before do
        legacy_reader.consume_relation(key)
      end

      it 'does not yield' do
        expect do |blk|
          legacy_reader.consume_relation(key, &blk)
        end.not_to yield_control
      end
    end

    context 'value is nil' do
      before do
        expect(legacy_reader).to receive(:tree_hash).and_return({ key => nil })
      end

      it 'does not yield' do
        expect do |blk|
          legacy_reader.consume_relation(key, &blk)
        end.not_to yield_control
      end
    end

    context 'value is not array' do
      before do
        expect(legacy_reader).to receive(:tree_hash).and_return({ key => 'value' })
      end

      it 'yield the value with 0 index' do
        expect do |blk|
          legacy_reader.consume_relation(key, &blk)
        end.to yield_with_args('value', 0)
      end
    end

    context 'value is an array' do
      before do
        expect(legacy_reader).to receive(:tree_hash).and_return({ key => %w[item1 item2 item3] })
      end

      it 'yield each array element with index' do
        expect do |blk|
          legacy_reader.consume_relation(key, &blk)
        end.to yield_successive_args(['item1', 0], ['item2', 1], ['item3', 2])
      end
    end
  end

  describe '#tree_hash' do
    let(:path) { fixture }

    subject { legacy_reader.send(:tree_hash) }

    it 'parses the JSON into the expected tree' do
      expect(subject).to eq(project_tree)
    end
  end
end
