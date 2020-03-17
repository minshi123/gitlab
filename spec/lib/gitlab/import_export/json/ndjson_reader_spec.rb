# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::JSON::NdjsonReader do
  let(:fixture) { 'spec/fixtures/lib/gitlab/import_export/light/tree' }
  let(:root_tree) { JSON.parse(File.read(File.join(fixture, 'project.ndjson'))) }
  let(:root) { :project }
  let(:ndjson_reader) { described_class.new(path, root) }

  describe '#valid?' do
    subject { ndjson_reader.valid? }

    context 'given valid path' do
      let(:path) { fixture }

      it { is_expected.to be true }
    end

    context 'given invalid path' do
      let(:path) { 'spec/non-existing-folder/do-not-create-this-file.json' }

      it { is_expected.to be false }
    end
  end

  describe '#legacy?' do
    let(:path) { fixture }

    subject { ndjson_reader.legacy? }

    it { is_expected.to be false }
  end

  describe '#root_attributes' do
    let(:path) { fixture }

    subject { ndjson_reader.root_attributes(excluded_attributes) }

    context 'No excluded attributes' do
      let(:excluded_attributes) { [] }

      it 'returns the whole tree from parsed JSON' do
        expect(subject).to eq(root_tree)
      end
    end

    context 'Some attributes are excluded' do
      let(:excluded_attributes) { %w[milestones labels issues services snippets] }

      before do
        ndjson_reader.consume_attribute('import_type')
        ndjson_reader.consume_attribute('archived')
      end

      it 'returns hash without excluded attributes and consumed attributes' do
        expect(subject).not_to include('milestones', 'labels', 'issues', 'services', 'snippets', 'import_type', 'archived')
      end
    end
  end

  describe '#consume_relation' do
    let(:path) { fixture }

    context 'key has been consumed' do
      let(:key) { 'issues' }

      before do
        ndjson_reader.consume_relation(key) do
        end
      end

      it 'does not yield' do
        expect do |blk|
          ndjson_reader.consume_relation(key, &blk)
        end.not_to yield_control
      end
    end

    context 'relation file does not exist' do
      let(:key) { 'this_relation_key_does_not_exists' }

      it 'does not yield' do
        expect do |blk|
          ndjson_reader.consume_relation(key, &blk)
        end.not_to yield_control
      end
    end

    context 'relation file contains multiple lines' do
      let(:key) { 'labels' }
      let(:label_1) { JSON.parse('{"id":2,"title":"A project label","color":"#428bca","project_id":8,"created_at":"2016-07-22T08:55:44.161Z","updated_at":"2016-07-22T08:55:44.161Z","template":false,"description":"","type":"ProjectLabel","priorities":[{"id":1,"project_id":5,"label_id":1,"priority":1,"created_at":"2016-10-18T09:35:43.338Z","updated_at":"2016-10-18T09:35:43.338Z"}]}') }
      let(:label_2) { JSON.parse('{"id":3,"title":"Another project label","color":"#428bca","project_id":8,"created_at":"2016-07-22T08:55:44.161Z","updated_at":"2016-07-22T08:55:44.161Z","template":false,"description":"","type":"ProjectLabel","priorities":[{"id":1,"project_id":5,"label_id":1,"priority":1,"created_at":"2016-10-18T09:35:43.338Z","updated_at":"2016-10-18T09:35:43.338Z"}]}') }

      it 'yield each line as json object with index' do
        expect do |blk|
          ndjson_reader.consume_relation(key, &blk)
        end.to yield_successive_args([label_1, 0], [label_2, 1])
      end
    end
  end
end
