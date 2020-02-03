# frozen_string_literal: true

module BulkInsertable
  extend ActiveSupport::Concern

  MethodDefinitionNotAllowedError = Class.new(StandardError)

  class_methods do
    def before_save(*)
      calling_method = caller_locations(1, 1).first&.label

      # this means we're called from a belongs_to assoc, which is OK
      if calling_method == 'add_autosave_association_callbacks'
        super
      else
        raise_not_allowed(:before_save)
      end
    end

    def after_save(*)
      raise_not_allowed(:after_save)
    end

    def before_create(*)
      raise_not_allowed(:before_create)
    end

    def after_create(*)
      raise_not_allowed(:after_create)
    end

    def before_commit(*)
      raise_not_allowed(:before_commit)
    end

    def after_commit(*)
      raise_not_allowed(:after_commit)
    end

    def around_save(*)
      raise_not_allowed(:around_save)
    end

    def around_create(*)
      raise_not_allowed(:around_create)
    end

    def before_validation(*)
      raise_not_allowed(:before_validation)
    end

    def after_validation(*)
      raise_not_allowed(:after_validation)
    end

    def validate(*)
      raise_not_allowed(:validate)
    end

    def validates(*)
      raise_not_allowed(:validates)
    end

    private

    def raise_not_allowed(method)
      raise MethodDefinitionNotAllowedError.new(
        "Not allowed to call `#{method}})` when model < `BulkInsertable`")
    end
  end
end
