# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Diff::StatsCache, :clean_gitlab_redis_cache do
  subject(:stats_cache) { described_class.new(diffable) }

  let(:diffable) { instance_double(MergeRequestDiff, cache_key: 'test') }
  let(:key) { ['diff_stats', diffable.cache_key, described_class::VERSION].join(":") }
  let(:cache) { Rails.cache }

  describe '#read' do
    it 'calls read on the cache with the expected key' do
      expect(cache).to receive(:fetch).with(key)

      stats_cache.read
    end
  end

  describe '#write_if_empty' do
    let(:stats) { [double(Gitaly::DiffStats, additions: 10, deletions: 15)] }

    context 'when the cached_values is present' do
      before do
        allow(cache).to receive(:fetch).and_return(stats)
        stats_cache.read
      end

      it 'does not write the stats' do
        expect(cache).not_to receive(:write)

        stats_cache.write_if_empty(stats)
      end
    end

    context 'when cached_values is blank' do
      it 'writes the stats' do
        expect(cache).to receive(:write).with(key, stats, expires_in: described_class::EXPIRATION)

        stats_cache.write_if_empty(stats)
      end
    end

    context 'when given empty stats' do
      let(:stats) { nil }

      it 'does not write the stats' do
        expect(cache).not_to receive(:write)

        stats_cache.write_if_empty(stats)
      end
    end
  end

  describe '#clear' do
    it 'clears cache' do
      expect_any_instance_of(Redis).to receive(:del).with(key)

      stats_cache.clear
    end
  end
end
