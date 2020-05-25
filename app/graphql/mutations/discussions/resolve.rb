# frozen_string_literal: true

module Mutations
  module Discussions
    class Resolve < Base
      graphql_name 'DiscussionResolve'

      def resolve(id:)
        discussion = authorized_find_discussion!(id: id)
        errors = []

        # `ResolveService` has no error state, and `discussion` has no
        # `errors` property, as it is a PORO. Instead the service can
        # raise an `ActiveRecord::RecordNotSaved` from any `Note` within
        # the `Discussion` that fails.
        #
        # As these errors should be returned within the response, capture
        # them and return in the mutation.
        begin
          ::Discussions::ResolveService.new(discussion.project, current_user).execute(discussion)
        rescue ActiveRecord::RecordNotSaved => e
          errors << e.message
        end

        {
          discussion: discussion,
          errors: errors
        }
      end
    end
  end
end
