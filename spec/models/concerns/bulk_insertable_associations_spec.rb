# frozen_string_literal: true

require 'fast_spec_helper'

describe BulkInsertableAssociations do
  class BulkInsertableItem < ApplicationRecord
    include BulkInsertable

    belongs_to :bulk_insert_parent
  end

  class BulkInsertParent < ApplicationRecord
    include BulkInsertableAssociations

    has_many :bulk_insertable_items
  end

  before(:all) do
    ActiveRecord::Schema.define do
      create_table :bulk_insert_parents, force: true do |t|
        t.string :name, null: true
      end

      create_table :bulk_insertable_items, force: true do |t|
        t.string :name, null: true
        t.belongs_to :bulk_insert_parent, null: true
      end
    end
  end

  after(:all) do
    ActiveRecord::Schema.define do
      drop_table :bulk_insertable_items, force: true
      drop_table :bulk_insert_parents, force: true
    end
  end

  before do
    ActiveRecord::Base.connection.execute('TRUNCATE bulk_insertable_items RESTART IDENTITY')
  end

  context 'saving bulk insertable associations' do
    let(:parent) { BulkInsertParent.create(name: 'parent') }

    context 'when items already have IDs' do
      it 'stores them all' do
        attributes = create_items(parent: parent) { |n, item| item.id = 100 + n }.map(&:attributes)

        BulkInsertParent.bulk_insert_on_save(:bulk_insertable_items, attributes)

        expect { parent.save! }.to change { BulkInsertableItem.count }.from(0).to(attributes.size)
        expect(parent.bulk_insertable_items.map(&:id)).to contain_exactly(*(100..109))
      end
    end

    context 'when items have no IDs set' do
      it 'stores them all and updates items with IDs' do
        items = create_items(parent: parent)
        attributes = items.map(&:attributes)

        BulkInsertParent.bulk_insert_on_save(:bulk_insertable_items, attributes)

        expect { parent.save! }.to change { BulkInsertableItem.count }.from(0).to(items.size)
        expect(parent.bulk_insertable_items.map(&:id)).to contain_exactly(*(1..10))
      end
    end
  end

  private

  def create_items(parent:, count: 10)
    Array.new(count) do |n|
      BulkInsertableItem.new(name: "item_#{n}", bulk_insert_parent_id: parent.id).tap do |item|
        yield(n, item) if block_given?
      end
    end
  end
end
