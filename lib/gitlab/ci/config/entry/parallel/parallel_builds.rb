# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        class Parallel
          class ParallelBuilds < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable

            validations do
              validates :config, numericality: { only_integer: true,
                                                 greater_than_or_equal_to: 2,
                                                 less_than_or_equal_to: 50 },
                                              allow_nil: true
            end

            def value
              super.to_i
            end
          end
        end
      end
    end
  end
end
