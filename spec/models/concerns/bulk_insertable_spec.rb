# frozen_string_literal: true

describe BulkInsertable do
  BLACKLISTED_METHODS = [
    :before_save, :after_save, :before_create, :after_create,
    :before_commit, :after_commit, :around_save, :around_create,
    :before_validation, :after_validation, :validate, :validates
  ].freeze

  class BulkInsertItem < ApplicationRecord
    include BulkInsertable
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

  context 'when calling class methods directly' do
    it 'raises an error when method is not bulk-insert safe' do
      BLACKLISTED_METHODS.each do |m|
        expect { BulkInsertItem.send(m, nil) }.to(
          raise_error(subject::MethodNotAllowedError),
          "Expected call to #{m} to raise an error, but it didn't"
        )
      end
    end

    it 'does not raise an error when method is bulk-insert safe' do
      expect { BulkInsertItem.after_initialize -> {} }.not_to raise_error
    end

    it 'does not raise an error when the call is triggered by belongs_to' do
      expect { BulkInsertItem.belongs_to(:other_record) }.not_to raise_error
    end
  end

  context 'when inheriting class methods' do
    it 'raises an error when method is not bulk-insert safe' do
      expect { BulkInsertItem.include(InheritedUnsafeMethods) }.to(
        raise_error(subject::MethodNotAllowedError))
    end

    it 'does not raise an error when method is bulk-insert safe' do
      expect { BulkInsertItem.include(InheritedSafeMethods) }.not_to raise_error
    end
  end
end
