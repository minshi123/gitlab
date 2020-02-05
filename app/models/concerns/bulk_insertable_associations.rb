# frozen_string_literal: true

module BulkInsertableAssociations
  extend ActiveSupport::Concern

  class_methods do
    def supports_bulk_insert?(association)
      reflect_on_association(association).klass < BulkInsertable
    end

    def bulk_insert_on_save(association, items)
      unless supports_bulk_insert?(association)
        raise "#{association} does not support bulk inserts"
      end

      _bulk_insert_context[association] ||= []
      _bulk_insert_context[association] += items
    end

    def _bulk_insert_context
      Thread.current['_bulk_insert_context'] ||= {}
    end
  end

  included do
    after_save :_flush_pending_bulk_inserts
  end

  private

  def _flush_pending_bulk_inserts
    model_class = self.class
    return unless model_class._bulk_insert_context&.any?

    model_class._bulk_insert_context.each do |association, items|
      association_class = model_class.reflect_on_association(association).klass
      items.each { |item| item.delete('id') unless item['id'] }
      association_class.insert_all(items, returning: ['id'])
    end

    Thread.current['_bulk_insert_context'] = nil
  end
end
