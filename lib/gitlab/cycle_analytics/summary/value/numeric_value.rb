# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module Summary
      module Value
        NumericValue = Struct.new(:value) do
          def to_s
            value.zero? ? '0' : value.to_s
          end
        end
      end
    end
  end
end
