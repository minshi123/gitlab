# frozen_string_literal: true

require 'rubocop/rspec/final_end_location'
require 'rubocop/rspec/blank_line_separation'
require 'rubocop/rspec/language'

module RuboCop
  module Cop
    module RSpec
      # Checks if there is an empty line after example blocks.
      #
      # @example
      #   # bad
      #   RSpec.describe Foo do
      #     it 'does this' do
      #     end
      #     it 'does that' do
      #     end
      #   end
      #
      #   # good
      #   RSpec.describe Foo do
      #     it 'does this' do
      #     end
      #
      #     it 'does that' do
      #     end
      #   end
      #
      #   # fair - it's ok to have non-separated one-liners
      #   RSpec.describe Foo do
      #     it { one }
      #     it { two }
      #   end
      #
      # @example with AllowConsecutiveOneLiners configuration
      #
      #   # rubocop.yml
      #   # RSpec/EmptyLineAfterExample:
      #   #   AllowConsecutiveOneLiners: false
      #
      #   # bad
      #   RSpec.describe Foo do
      #     it { one }
      #     it { two }
      #   end
      #
      class EmptyLineAfterSharedExample < RuboCop::Cop::Cop
        include RuboCop::RSpec::BlankLineSeparation
        include RuboCop::RSpec::Language

        MSG = 'Add an empty line after `%<example>s`.'

        def_node_matcher :shared_examples,
                         (SharedGroups::ALL + Includes::ALL).block_pattern

        def on_block(node)
          shared_examples(node) do
            return if last_child?(node)
            return if allowed_one_liner?(node)

            missing_separating_line(node) do |location|
              add_offense(node,
                          location: location,
                          message: format(MSG, example: node.method_name))
            end
          end
        end

        def allowed_one_liner?(node)
          consecutive_one_liner?(node) && allow_consecutive_one_liners?
        end

        def allow_consecutive_one_liners?
          cop_config['AllowConsecutiveOneLiners']
        end

        def consecutive_one_liner?(node)
          node.line_count == 1 && next_one_line_example?(node)
        end

        def next_one_line_example?(node)
          next_sibling = next_sibling(node)
          return unless next_sibling
          return unless example?(next_sibling)

          next_sibling.line_count == 1
        end

        def next_sibling(node)
          node.parent.children[node.sibling_index + 1]
        end
      end
    end
  end
end
