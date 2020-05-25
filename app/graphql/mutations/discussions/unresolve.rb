# frozen_string_literal: true

module Mutations
  module Discussions
    class Unresolve < Base
      graphql_name 'DiscussionUnresolve'

      def resolve(id:)
        discussion = authorized_find_discussion!(id: id)
        errors = []

        # `discussion` has no `errors` property, as it is a PORO,
        # but instead the `#unresolve!` method will raise `ActiveRecord::RecordNotSaved`
        # from any `Note` within `discussion` that fails.
        #
        # As these errors should be returned within the response, capture
        # them and return in the mutation.
        begin
          discussion.unresolve!
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
