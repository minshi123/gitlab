# frozen_string_literal: true

module Gitlab
  class GlRepository
    class IdentifierParser
      attr_reader :gl_repository, :segments, :type, :id, :container_class, :three_segments_format
      alias_method :three_segments_format?, :three_segments_format

      def initialize(gl_repository)
        @gl_repository = gl_repository
        @segments = gl_repository.split('-')

        # gl_repository can either have 2 or 3 segments:
        # "wiki-1" is the older 2-segment format, where container is implied.
        # "group-1-wiki" is the newer 3-segment format, including container information.
        @three_segments_format = @segments.size == 3

        @type = find_type
        @id = find_id
        @container_class = find_container_class
      end

      def fetch_container!
        container_class.find_by_id(id)
      end

      private

      def find_type
        type_name = three_segments_format? ? segments.last : segments.first
        type = Gitlab::GlRepository.types[type_name]

        raise_error unless type

        type
      end

      def find_container_class
        if three_segments_format?
          case segments[0]
          when 'project'
            Project
          when 'group'
            Group
          else
            raise_error
          end
        else
          type.container_class
        end
      end

      def find_id
        id = Integer(segments[1], 10, exception: false)

        raise_error unless id

        id
      end

      def raise_error
        raise ArgumentError, "Invalid GL Repository \"#{gl_repository}\""
      end
    end
  end
end
