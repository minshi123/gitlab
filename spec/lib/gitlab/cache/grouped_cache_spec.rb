require 'spec_helper'

describe Gitlab::Cache::GroupedCache, :clean_gitlab_redis_cache do
  describe '.fetch' do
    it 'remembers the result of the first invocation' do
      expect(described_class.fetch(:new_group, :key1) { "value1" }).to eq("value1")
      expect(described_class.fetch(:new_group, :key2) { "value2" }).to eq("value2")

      expect { |b| described_class.fetch(:new_group, :key1, &b) }.not_to yield_control
      expect { |b| described_class.fetch(:new_group, :key2, &b) }.not_to yield_control

      expect(described_class.fetch(:new_group, :key1) { "not-invoked" }).to eq("value1")
      expect(described_class.fetch(:new_group, :key2) { "not-called" }).to eq("value2")
    end

    it 'allows setting a expires_in to expire the cache' do
      expect(described_class.fetch(:new_group, :key1, expires_in: 0) { "value1" }).to eq("value1")
      expect(described_class.fetch(:new_group, :key2, expires_in: 0) { "value2" }).to eq("value2")

      expect(described_class.fetch(:new_group, :key1, expires_in: 0) { "new-value1" }).to eq("new-value1")
      expect(described_class.fetch(:new_group, :key2, expires_in: 0) { "new-value2" }).to eq("new-value2")
    end
  end

  describe '.delete' do
    it 'clears the cached value' do
      expect(described_class.fetch(:new_group, :key1) { "value1" }).to eq("value1")
      expect(described_class.fetch(:new_group, :key2) { "value2" }).to eq("value2")

      described_class.delete(:new_group)

      expect(described_class.fetch(:new_group, :key1) { "new-value1" }).to eq("new-value1")
      expect(described_class.fetch(:new_group, :key2) { "new-value2" }).to eq("new-value2")
    end

    it 'does not clear the cache for another group' do
      expect(described_class.fetch(:group1, :key) { "value1" }).to eq("value1")
      expect(described_class.fetch(:group2, :key) { "value2" }).to eq("value2")

      described_class.delete(:group1)

      expect(described_class.fetch(:group1, :key) { "new-value1" }).to eq("new-value1")
      expect(described_class.fetch(:group2, :key) { "new-value2" }).to eq("value2")
    end
  end
end
