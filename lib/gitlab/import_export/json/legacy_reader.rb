# frozen_string_literal: true

module Gitlab
  module ImportExport
    module JSON
      class LegacyReader
        class File < LegacyReader
          def initialize(path)
            @path = path
            @logger = Gitlab::Import::Logger.build
          end

          def valid?
            ::File.exist?(@path)
          end

          protected

          def tree_hash
            @tree_hash ||= read_hash
          end

          def read_hash
            ActiveSupport::JSON.decode(IO.read(@path))
          rescue => e
            @logger.error(message: "Import/Export error: #{e.message}")
            raise Gitlab::ImportExport::Error.new('Incorrect JSON format')
          end
        end

        class User < LegacyReader
          def initialize(tree_hash)
            @tree_hash = tree_hash
          end

          def valid?
            @tree_hash.present?
          end

          protected

          attr_reader :tree_hash
        end

        def valid?
          raise NotImplementedError
        end

        def root_attributes(excluded_attributes = [])
          tree_hash.reject do |key, _|
            excluded_attributes.include?(key)
          end
        end

        def consume_relation(key)
          value = delete(key)
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

        def delete(key)
          tree_hash.delete(key)
        end

        protected

        def tree_hash
          raise NotImplementedError
        end
      end
    end
  end
end
