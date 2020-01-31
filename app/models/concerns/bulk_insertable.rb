# frozen_string_literal: true

module BulkInsertable
  MethodDefinitionNotAllowedError = Class.new(StandardError)

  BLACKLISTED_METHODS = [
    :before_save, :after_save, :before_create, :after_create,
    :before_commit, :after_commit, :around_save, :around_create,
    :before_validation, :after_validation, :validate, :validates
  ].freeze

  BLACKLISTED_METHODS.each do |hook|
    define_method(hook) do |*args|
      raise MethodDefinitionNotAllowedError.new(
        "Not allowed to call `#{hook}(args: #{args.inspect})` when model < `BulkInsertable`")
    end
  end
end
