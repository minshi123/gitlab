# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents a key.
        #
        class Parallel < ::Gitlab::Config::Entry::Simplifiable
          strategy :ParallelBuilds, if: -> (config) { config.is_a?(Numeric) }
          strategy :MatrixBuilds, if: -> (config) { config.is_a?(Hash) }

          def location
            "dsfasd"
          end

          class UnknownStrategy < ::Gitlab::Config::Entry::Node
            def errors
              ["#{location} should be an integer or a hash"]
            end
          end
        end
      end
    end
  end
end
