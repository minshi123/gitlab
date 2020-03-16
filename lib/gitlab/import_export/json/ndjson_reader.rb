# frozen_string_literal: true

module Gitlab
  module ImportExport
    module JSON
      class NdjsonReader
        include Gitlab::ImportExport::CommandLineUtil

        attr_reader :dir_path, :root

        def initialize(dir_path, root)
          @dir_path = dir_path
          @root = root
          @consumed_relations = []
          @consumed_attributes = []
        end

        def valid?
          File.exist?(file_path(root))
        end

        def legacy?
          false
        end

        def root_attributes(excluded_attributes = [])
          excluded_attributes.concat(@consumed_attributes).uniq

          consume_relation(root) do |hash|
            return hash.reject do |key, _|
              excluded_attributes.include?(key)
            end
          end
        end

        def consume_relation(key)
          return if @consumed_relations.include?(key)

          @consumed_relations << key

          return unless File.exist?(file_path(key))

          File.foreach(file_path(key)).with_index do |line, line_num|
            json = ActiveSupport::JSON.decode(line)
            yield(json, line_num)
          end
        end

        def consume_attribute(key)
          @consumed_attributes << key
        end

        private

        def file_path(key)
          File.join(@dir_path, "#{key}.ndjson")
        end
      end
    end
  end
end
