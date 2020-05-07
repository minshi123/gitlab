# frozen_string_literal: true

module Gitlab
  module CycleAnalytics
    module Summary
      module Value
        PrettyNumeric = Struct.new(:value) do
          def to_s
            # 0 is shown as -
            value.nonzero? ? NumericValue.new(value).to_s : NoValue.new.to_s
          end
        end
      end
    end
  end
end
