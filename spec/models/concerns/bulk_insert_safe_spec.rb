# frozen_string_literal: true

require 'spec_helper'

describe BulkInsertSafe do
  class BulkInsertItem < ApplicationRecord
    include BulkInsertSafe

    validates :name, presence: true
  end

  class BulkInsertSerialIdItem < ApplicationRecord
    include BulkInsertSafe
  end

  module InheritedUnsafeMethods
    extend ActiveSupport::Concern

    included do
      after_save -> { "unsafe" }
    end
  end

  module InheritedSafeMethods
    extend ActiveSupport::Concern

    included do
      after_initialize -> { "safe" }
    end
  end

  before(:all) do
    ActiveRecord::Schema.define do
      create_table :bulk_insert_items, force: true, id: false do |t|
        t.integer :item_id, null: false, primary_key: true
        t.string :name, null: true
      end
      create_table :bulk_insert_serial_id_items, force: true, id: :serial do |t|
        t.string :name, null: true
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :bulk_insert_items, force: true
      drop_table :bulk_insert_serial_id_items, force: true
    end
  end

  def build_valid_items_for_bulk_insertion
    Array.new(10) do |n|
      BulkInsertItem.new(item_id: n, name: "item-#{n}")
    end
  end

  def build_invalid_items_for_bulk_insertion
    Array.new(10) do |n|
      BulkInsertItem.new(item_id: n) # requires `name` to be set
    end
  end

  it_behaves_like 'a BulkInsertSafe model', BulkInsertItem

  context 'when inheriting class methods' do
    it 'raises an error when method is not bulk-insert safe' do
      expect { BulkInsertItem.include(InheritedUnsafeMethods) }.to(
        raise_error(subject::MethodNotAllowedError))
    end

    it 'does not raise an error when method is bulk-insert safe' do
      expect { BulkInsertItem.include(InheritedSafeMethods) }.not_to raise_error
    end
  end

  context 'primary keys' do
    it 'recognizes custom primary keys' do
      items = build_valid_items_for_bulk_insertion

      BulkInsertItem.bulk_insert!(items)

      existing_item_id = items.last.item_id
      expect { BulkInsertItem.create!(item_id: existing_item_id, name: 'item') }.to(
        raise_error(ActiveRecord::RecordNotUnique)
      )
    end

    it 'drops nil primary keys to prevent not-null constraint violations' do
      items = [BulkInsertSerialIdItem.new]
      expect(items.map(&:id)).to all(be nil)

      expect { BulkInsertSerialIdItem.bulk_insert!(items) }.not_to raise_error
    end
  end

  describe '.bulk_insert' do
    it 'inserts items in the given number of batches' do
      items = build_valid_items_for_bulk_insertion
      expect(items.size).to eq(10)
      expect(BulkInsertItem).to receive(:insert_all).twice

      BulkInsertItem.bulk_insert(items, batch_size: 5)
    end

    it 'rolls back the transaction when any item is invalid' do
      valid_items = build_valid_items_for_bulk_insertion
      invalid_items = build_invalid_items_for_bulk_insertion
      all_items = valid_items + invalid_items # second batch is bad
      batch_size = all_items.size / 2

      expect { BulkInsertItem.bulk_insert(all_items, batch_size: batch_size) }.not_to(
        change { BulkInsertItem.count }
      )
    end

    it 'does nothing and returns true when items are empty' do
      expect(BulkInsertItem.bulk_insert([])).to be(true)
      expect(BulkInsertItem.count).to eq(0)
    end
  end

  describe '.bulk_insert!' do
    it 'inserts items in the given number of batches' do
      items = build_valid_items_for_bulk_insertion
      expect(items.size).to eq(10)
      expect(BulkInsertItem).to receive(:insert_all!).twice

      BulkInsertItem.bulk_insert!(items, batch_size: 5)
    end

    it 'rolls back the transaction when any item is invalid' do
      valid_items = build_valid_items_for_bulk_insertion
      invalid_items = build_invalid_items_for_bulk_insertion
      all_items = valid_items + invalid_items # second batch is bad
      batch_size = all_items.size / 2

      expect do
        BulkInsertItem.bulk_insert!(all_items, batch_size: batch_size) rescue nil
      end.not_to(
        change { BulkInsertItem.count }
      )
    end

    it 'does nothing and returns true when items are empty' do
      expect(BulkInsertItem.bulk_insert!([])).to be(true)
      expect(BulkInsertItem.count).to eq(0)
    end
  end
end
