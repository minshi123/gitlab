# frozen_string_literal: true

# ActiveRecord model classes can mix in this concern if they own associations
# who declare themselves to be eligible for bulk-insertion via `BulkInsertSafe`.
# This allows the caller to schedule association items to be written in bulk
# whenever the owner is `save`d.
#
# USAGE:
#
#   class MergeRequestDiff < ApplicationRecord
#     include BulkInsertableAssociations
#
#     # target association class must `include BulkInsertSafe`
#     has_many :merge_request_diff_commits
#   end
#
#   diff = MergeRequestDiff.new(...)
#   diff_commits = [MergeRequestDiffCommit.new(...), ...]
#   diff.bulk_insert_on_save(:merge_request_diff_commits, diff_commits)
#   ...
#   diff.save # this will also write all `diff_commits` in bulk
#
# If you are not sure whether the owning type defines `bulk_insert_on_save`
# you can also "attempt" a bulk-insertion via the `try_bulk_insert_on_save`
# helper. It will return `true` or `false` to indicate success.
#
# Note that just like `BulkInsertSafe.bulk_insert`, validations will run for
# all items that are scheduled for bulk-insertions. It also supports the
# :batch_size option to specify how many items should be inserted at once.
#
module BulkInsertableAssociations
  extend ActiveSupport::Concern

  MissingAssociationError = Class.new(StandardError)
  NotBulkInsertSafeError = Class.new(StandardError)

  class_methods do
    def supports_bulk_insert?(association)
      association_class_for(association) < BulkInsertSafe
    end

    def bulk_insert_on_save(association, items, batch_size: BulkInsertSafe::DEFAULT_BATCH_SIZE)
      return if items.empty?

      unless supports_bulk_insert?(association)
        raise NotBulkInsertSafeError.new("#{association} does not support bulk inserts; " \
          "the associated type must include the `BulkInsertSafe` concern")
      end

      pending_association_items[association] ||= {}
      pending_association_items[association][:batch_size] = batch_size
      pending_association_items[association][:items] ||= []
      pending_association_items[association][:items] += items
    end

    # Returns a hash of association symbols mapped to a list of AR instances
    # that had been flushed. Method calls are idempotent.
    def flush_pending_bulk_inserts(model_instance)
      return {} unless pending_association_items&.any?

      pending_association_items.each do |association, config|
        items = config[:items]
        batch_size = config[:batch_size]
        association_class = association_class_for(association)
        # Note that we suppress validations here because we already run validations
        # on all pending bulk-inserts when we `save` the parent
        association_class.bulk_insert(items, validate: false, batch_size: batch_size) do |item_attributes|
          # wires up the foreign key column with the owner of this association
          owner_id_attribute = reflections[association.to_s].foreign_key
          item_attributes[owner_id_attribute] = model_instance.id
        end
      end
    ensure
      clear_pending_association_items
    end

    def validate_pending_bulk_inserts(model_instance)
      pending_association_items.each do |key, config|
        config[:items].each do |item|
          unless item.valid?
            item.errors.full_messages.each do |item_error|
              model_instance.errors.add(key, item_error)
            end
          end
        end
      end
    end

    private

    def pending_association_items
      bulk_insert_context[self] ||= {}
    end

    def clear_pending_association_items
      bulk_insert_context.delete(self)
    end

    def bulk_insert_context
      Thread.current['_bulk_insert_context'] ||= {}
    end

    def association_class_for(association)
      reflection = reflect_on_association(association)
      unless reflection
        raise MissingAssociationError.new("#{self} does not define association #{association}")
      end

      reflection.klass
    end
  end

  def validate_pending_bulk_inserts
    self.class.validate_pending_bulk_inserts(self)
  end

  included do
    delegate :bulk_insert_on_save, to: self
    delegate :flush_pending_bulk_inserts, to: self

    validate :validate_pending_bulk_inserts

    after_save { flush_pending_bulk_inserts(self) }
  end
end
