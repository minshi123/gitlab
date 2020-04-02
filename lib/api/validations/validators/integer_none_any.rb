# frozen_string_literal: true

module API
  module Validations
    module Validators
      class IntegerNoneAny < Grape::Validations::Base
        def validate_param!(attr_name, params)
          value = params[attr_name]

          return if value.is_a?(Integer) ||
              [IssuableFinder::Params::FILTER_NONE, IssuableFinder::Params::FILTER_ANY].include?(value.to_s.downcase)

          raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)],
                                               message: "should be an integer, 'None' or 'Any'"
        end
      end
    end
  end
end
