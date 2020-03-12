# frozen_string_literal: true

module Gitlab
  module ImportExport
    module JSON
      class LegacyReader
        attr_reader :path

        def initialize(path, tree_hash: nil)
          @path = path
          @tree_hash = tree_hash
          @consumed_relations = []
        end

        def valid?
          File.exist?(@path)
        end

        def root_attributes(excluded_attributes = [])
          tree_hash.reject do |key, _|
            excluded_attributes.include?(key) || @consumed_relations.include?(key)
          end
        end

        def consume_relation(key)
          return if @consumed_relations.include?(key)

          @consumed_relations << key

          value = tree_hash[key]
          return if value.nil?

          return unless block_given?

          if value.is_a?(Array)
            value.each.with_index do |item, idx|
              yield(item, idx)
            end
          else
            yield(value, 0)
          end
        end

        def transform_relation!(key)
          return unless tree_hash[key].is_a?(Array)

          yield(tree_hash[key])
        end

        protected

        def tree_hash
          @tree_hash ||= read_hash
        end

        def read_hash
          ActiveSupport::JSON.decode(IO.read(@path))
        rescue => e
          Rails.logger.error("Import/Export error: #{e.message}") # rubocop:disable Gitlab/RailsLogger
          raise Gitlab::ImportExport::Error.new('Incorrect JSON format')
        end
      end
    end
  end
end
