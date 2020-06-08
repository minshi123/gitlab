# frozen_string_literal: true

require "spec_helper"

describe Gitlab::Git::DiffStatsCollection do
  let(:stats_a) do
    Gitaly::DiffStats.new(additions: 10, deletions: 15, path: 'foo')
  end

  let(:stats_b) do
    Gitaly::DiffStats.new(additions: 5, deletions: 1, path: 'bar')
  end

  let(:diff_stats) { [stats_a, stats_b] }
  let(:collection) { described_class.new(diff_stats) }

  describe '#find_by_path' do
    it 'returns stats by path when found' do
      expect(collection.find_by_path('foo')).to eq(stats_a)
    end

    it 'returns nil when stats is not found by path' do
      expect(collection.find_by_path('no-file')).to be_nil
    end
  end

  describe '#paths' do
    it 'returns only modified paths' do
      expect(collection.paths).to eq %w[foo bar]
    end
  end

  describe '#real_size' do
    it 'returns the number of modified files' do
      expect(collection.real_size).to eq('2')
    end

    it 'returns capped number when it is bigger than max_files' do
      allow(::Commit).to receive(:max_diff_options).and_return(max_files: 1)

      expect(collection.real_size).to eq('1+')
    end
  end

  describe '#marshalling data' do
    it 'allows us to load the dumped data' do
      dumped_data = collection.marshal_dump

      loaded_collection = described_class.new([])
      loaded_collection.marshal_load(dumped_data)

      expect(loaded_collection.to_a).to eq(collection.to_a)
    end
  end
end
