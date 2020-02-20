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

    def bulk_insert(items, validate: true, batch_size: DEFAULT_BATCH_SIZE, &handle_attributes)
      return true if items.empty?
      return false if validate && !items.all?(&:valid?)

      items.each_slice(batch_size) do |item_batch|
        insert_all(_bulk_insert_attributes(item_batch, &handle_attributes))
      end

      true
    end

    def bulk_insert!(items, validate: true, batch_size: DEFAULT_BATCH_SIZE, &handle_attributes)
      return true if items.empty?

      items.each(&:validate!) if validate
      items.each_slice(batch_size) do |item_batch|
        insert_all!(_bulk_insert_attributes(item_batch, &handle_attributes))
      end

      true
    end

    private

    def _bulk_insert_attributes(items)
      items.map do |item|
        attributes = item.attributes
        attributes.delete('id') unless attributes['id']
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
