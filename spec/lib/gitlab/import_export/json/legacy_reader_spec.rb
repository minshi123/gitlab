# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::ImportExport::JSON::LegacyReader do
  let(:fixture) { 'spec/fixtures/lib/gitlab/import_export/with_duplicates.json' }
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

#   context 'without de-duplicating entries' do
#     let(:parsed_tree) do
#       subject.load(fixture)
#     end
# 
#     it 'parses the JSON into the expected tree' do
#       expect(parsed_tree).to eq(project_tree)
#     end
# 
#     it 'does not de-duplicate entries' do
#       expect(parsed_tree['duped_hash_with_id']).not_to be(parsed_tree['array'][0]['duped_hash_with_id'])
#     end
#   end
# 
#   context 'with de-duplicating entries' do
#     let(:parsed_tree) do
#       subject.load(fixture, dedup_entries: true)
#     end
# 
#     it 'parses the JSON into the expected tree' do
#       expect(parsed_tree).to eq(project_tree)
#     end
# 
#     it 'de-duplicates equal values' do
#       expect(parsed_tree['duped_hash_with_id']).to be(parsed_tree['array'][0]['duped_hash_with_id'])
#       expect(parsed_tree['duped_hash_with_id']).to be(parsed_tree['nested']['duped_hash_with_id'])
#       expect(parsed_tree['duped_array']).to be(parsed_tree['array'][1]['duped_array'])
#       expect(parsed_tree['duped_array']).to be(parsed_tree['nested']['duped_array'])
#     end
# 
#     it 'does not de-duplicate hashes without IDs' do
#       expect(parsed_tree['duped_hash_no_id']).to eq(parsed_tree['array'][2]['duped_hash_no_id'])
#       expect(parsed_tree['duped_hash_no_id']).not_to be(parsed_tree['array'][2]['duped_hash_no_id'])
#     end
# 
#     it 'keeps single entries intact' do
#       expect(parsed_tree['simple']).to eq(42)
#       expect(parsed_tree['nested']['array']).to eq(["don't touch"])
#     end
#   end
end
