# frozen_string_literal: true

module Resolvers
  module DesignManagement
    class DesignResolver < BaseResolver
      argument :id, GraphQL::ID_TYPE,
               required: false,
               description: 'Find a design by its ID'

      argument :filename, GraphQL::STRING_TYPE,
               required: false,
               description: 'Find a design by its filename'

      def resolve(filename: nil, id: nil)
        params = parse_args(filename, id)

        case params
        when :no_args then error('one of id or filename must be passed')
        when :both_args then error('only one of id or filename may be passed')
        end

        build_finder(params).execute.first
      end

      def self.single
        self
      end

      private

      def issue
        object.issue
      end

      def user
        context[:current_user]
      end

      def build_finder(params)
        ::DesignManagement::DesignsFinder.new(issue, user, params)
      end

      def error(msg)
        raise ::Gitlab::Graphql::Errors::ArgumentError, msg
      end

      def parse_args(filename, id)
        (use_filename, _) = provided = [filename, id].map(&:present?)

        return :no_args if provided.none?

        return :both_args if provided.all?

        return { filenames: [filename] } if use_filename

        { ids: [parse_gid(id)] }
      end

      def parse_gid(gid)
        GitlabSchema.parse_gid(gid, expected_type: ::DesignManagement::Design).model_id
      end
    end
  end
end
