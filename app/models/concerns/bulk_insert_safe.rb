# frozen_string_literal: true

# A mixin for ActiveRecord models that enables callers to insert instances of the
# target class into the database en-bloc via the `bulk_insert` method.
#
# Upon inclusion in the target class, the mixin will perform a number of checks to
# ensure that the target is eligible for bulk insertions. For instance, it must not
# use ActiveRecord callbacks that fire between `save`s, since these would not run
# properly when instances are inserted in bulk.
#
# The mixin uses ActiveRecord 6's `InsertAll` type internally for bulk insertions.
# Unlike `InsertAll`, however, it requires you to pass instances of the target type
# rather than row hashes, since it will run validations prior to insertion.
#
# USAGE:
#
#   class MyRecord < ApplicationRecord
#     include BulkInsertSafe # must be included _last_ i.e. after any other concerns
#   end
#
#   # simple
#   MyRecord.bulk_insert(items)
#
#   # with custom batch size
#   MyRecord.bulk_insert(items, batch_size: 100)
#
#   # without validations
#   MyRecord.bulk_insert(items, validate: false)
#
#   # with attribute hash modification
#   MyRecord.bulk_insert(items) { |item_attrs| item_attrs['col'] = 42 }
#
# There is also a bang variant of the method, which throws on validation failures or
# duplicate row errors.
#
module BulkInsertSafe
  extend ActiveSupport::Concern

  # These are the callbacks we think safe when used on models that are
  # written to the database in bulk
  CALLBACK_NAME_WHITELIST = Set[
    :initialize,
    :validate,
    :validation,
    :find,
    :destroy
  ].freeze

  DEFAULT_BATCH_SIZE = 500

  MethodNotAllowedError = Class.new(StandardError)

  class_methods do
    def set_callback(name, *args)
      unless _bulk_insert_callback_allowed?(name, args)
        raise MethodNotAllowedError.new(
          "Not allowed to call `set_callback(#{name}, #{args})` when model extends `BulkInsertSafe`." \
            "Callbacks that fire per each record being inserted do not work with bulk-inserts.")
      end

      super
    end

    # This method does not raise errors in case of:
    # - validation failures
    # - primary key collisions
    #
    # If items are inserted in multiple batches, either all or no batches will be inserted.
    # Duplicate rows are ignored. Returns false if any items failed to validate, true otherwise.
    def bulk_insert(items, validate: true, batch_size: DEFAULT_BATCH_SIZE, &handle_attributes)
      _bulk_insert_internal(
        items, validate: validate, batch_size: batch_size, raise_errors: false, &handle_attributes
      )
    end

    # Unlike `bulk_insert`, this method raises errors in case of:
    # - validation failures
    # - primary key collisions
    #
    # If items are inserted in multiple batches, either all or no batches will be inserted.
    # Returns true if all items succeeded to be inserted, throws otherwise.
    def bulk_insert!(items, validate: true, batch_size: DEFAULT_BATCH_SIZE, &handle_attributes)
      _bulk_insert_internal(
        items, validate: validate, batch_size: batch_size, raise_errors: true, &handle_attributes
      )
    end

    private

    def _bulk_insert_internal(items, validate:, batch_size:, raise_errors:, &handle_attributes)
      return true if items.empty?

      transaction do
        items.each_slice(batch_size) do |item_batch|
          attributes = _bulk_insert_item_attributes(item_batch, validate, &handle_attributes)

          raise_errors ? insert_all!(attributes) : insert_all(attributes)
        end
      end

      true
    rescue => e
      raise e if raise_errors

      false
    end

    def _bulk_insert_item_attributes(items, validate_items)
      items.map do |item|
        attributes = item.attributes

        item.validate! if validate_items

        primary_key = item.class.primary_key
        # Drop `primary_key` column entries that have a `nil` value, as that would
        # most certainly lead to constraint violations upon insertion when the
        # primary key is a :serial column.
        if primary_key && attributes.key?(primary_key) && attributes[primary_key].nil?
          attributes.delete(primary_key)
        end

        yield attributes if block_given?

        attributes
      end
    end

    def _bulk_insert_callback_allowed?(name, args)
      _bulk_insert_whitelisted?(name) || _bulk_insert_saved_from_belongs_to?(name, args)
    end

    # belongs_to associations will install a before_save hook during class loading
    def _bulk_insert_saved_from_belongs_to?(name, args)
      args.first == :before && args.second.to_s.start_with?('autosave_associated_records_for_')
    end

    def _bulk_insert_whitelisted?(name)
      CALLBACK_NAME_WHITELIST.include?(name)
    end
  end
end
