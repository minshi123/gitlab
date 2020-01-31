# frozen_string_literal: true

describe BulkInsertable do
  class BulkInsertItem < ApplicationRecord
    extend BulkInsertable
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
      subject::BLACKLISTED_METHODS.each do |m|
        expect { BulkInsertItem.send(m, nil) }.to(
          raise_error(BulkInsertable::MethodDefinitionNotAllowedError),
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
        raise_error(BulkInsertable::MethodDefinitionNotAllowedError))
    end

    it 'does not raise an error when method is bulk-insert safe' do
      expect { BulkInsertItem.include(InheritedSafeMethods) }.not_to raise_error
    end
  end
end
