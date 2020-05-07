# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module Summary
      module Value
        class NoValue
          def to_s
            '-'
          end
        end
      end
    end
  end
end
