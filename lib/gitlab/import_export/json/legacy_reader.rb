# frozen_string_literal: true

module Gitlab
  module ImportExport
    module JSON
      class LegacyReader
        attr_reader :path

        def initialize(path, tree_hash: nil)
          @path = path
          @tree_hash = tree_hash
          @deleted_relations = []
        end

        def valid?
          File.exist?(@path)
        end

        def root_attributes(excluded_attributes = [])
          tree_hash.reject do |key, _|
            excluded_attributes.include?(key) || @deleted_relations.include?(key)
          end
        end

        def mark_relations_as_deleted(keys)
          return unless keys

          @deleted_relations.concat(keys).uniq
        end

        def each_relation(key)
          return if @deleted_relations.include?(key)

          value = tree_hash[key]
          return if value.nil?

          if value.is_a?(Array)
            value.each.with_index do |item, idx|
              yield(item, idx)
            end
          else
            yield(value, 0)
          end
        end

        protected

        def tree_hash
          @tree_hash ||= read_hash
        end

        def read_hash
          ActiveSupport::JSON.decode(IO.read(@path))
        end
      end
    end
  end
end
