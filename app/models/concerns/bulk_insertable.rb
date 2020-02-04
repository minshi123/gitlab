# frozen_string_literal: true

module BulkInsertable
  extend ActiveSupport::Concern

  CALLBACK_BLACKLIST = [
    :save,
    :create,
    :before_commit,
    :commit,
    :validation
  ].freeze

  MethodNotAllowedError = Class.new(StandardError)

  class_methods do
    def set_callback(name, *args)
      if callback_allowed?(name, args)
        super
      else
        raise_not_allowed("set_callback(#{name}, #{args})")
      end
    end

    def validate(*)
      raise_not_allowed(:validate)
    end

    def validates(*)
      raise_not_allowed(:validates)
    end

    private

    def callback_allowed?(name, args)
      !blacklisted?(name) || save_from_belongs_to?(name, args)
    end

    def blacklisted?(name)
      CALLBACK_BLACKLIST.include?(name)
    end

    # belongs_to associations will install a before_save hook during class loading
    def save_from_belongs_to?(name, args)
      args.first == :before && args.second.to_s.start_with?('autosave_associated_records_for_')
    end

    def raise_not_allowed(invocation)
      raise MethodNotAllowedError.new(
        "Not allowed to call `#{invocation}` when model < `BulkInsertable`")
    end
  end
end
