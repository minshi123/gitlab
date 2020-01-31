# frozen_string_literal: true

module BulkInsertable
  MethodDefinitionNotAllowedError = Class.new(StandardError)

  BLACKLISTED_METHODS = [
    :before_save, :after_save, :before_create, :after_create,
    :before_commit, :after_commit, :around_save, :around_create,
    :before_validation, :after_validation, :validate, :validates
  ].freeze

  BLACKLISTED_METHODS.each do |method|
    define_method(method) do |*args|
      return super(args) if _bi_allow_method?(method, args)

      raise MethodDefinitionNotAllowedError.new(
        "Not allowed to call `#{method}(args: #{args.inspect})` when model < `BulkInsertable`")
    end
  end

  private

  def _bi_allow_method?(method, args)
    _bi_before_save_called_from_belongs_to?(method, args)
  end

  def _bi_before_save_called_from_belongs_to?(method, args)
    method == :before_save && args&.first.to_s.start_with?('autosave_associated_records_for_')
  end
end
