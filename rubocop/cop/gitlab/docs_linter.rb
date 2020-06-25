# frozen_string_literal: true

require_relative '../../code_reuse_helpers'

module RuboCop
  module Cop
    module Gitlab
      class DocsLinter < RuboCop::Cop::Cop
        include CodeReuseHelpers

        MSG = 'help_page_path points to incorrect path'

        def_node_matcher :help_page_path?, <<~PATTERN
        (send nil? :link_to
           (send ...)
           (send nil? :help_page_path ...)
           ...
        )
        PATTERN

        def on_send(node)
          return unless help_page_path?(node)
          return if documentation_exists?(node)

          add_offense(node, location: :selector)
        end

        private

        def documentation_exists?(node)
          File.exists?(
            File.join(rails_root, 'doc', path_to_help(node))
          )
        end

        def path_to_help(node)
          node.arguments[1].child_nodes.first.value
        end
      end
    end
  end
end
