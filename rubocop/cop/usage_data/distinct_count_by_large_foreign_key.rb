module RuboCop
  module Cop
    module UsageData
      # Disallows counts by large table's foreign keys for `distinct_count` method.
      #
      # Such distinct_counts will take a lot of time
      #
      # @example
      #
      #   # bad because pipeline_id points to a large table
      #   distinct_count(Ci::Build, :commit_id)
      #
      class DistinctCountByLargeForeignKey < RuboCop::Cop::Cop
        MSG = 'Avoid doing `%s` for large foreign keys.'.freeze

        def_node_matcher :distinct_count?, <<-PATTERN
          (send _ ${:distinct_count} ...)
        PATTERN

        def on_send(node)
          distinct_count?(node) do |match|
            next unless node.arguments? && node.arguments.length >= 2
            next unless disallowed_foreign_key?(node.arguments[1])

            add_offense(node, location: :selector, message: format(MSG, match))
          end
        end

        private

        def disallowed_foreign_key?(key)
          key.type == :sym && !allowed_foreign_keys.include?(key.value)
        end

        def allowed_foreign_keys
          cop_config['AllowedForeignKeys'] || []
        end
      end
    end
  end
end
