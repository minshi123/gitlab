# frozen_string_literal: true

module Resolvers
  class UsersResolver < BaseResolver
    description 'Find Users'

    argument    :ids, [GraphQL::ID_TYPE], required: false,
                description: 'List of user IDs'

    argument    :usernames, [GraphQL::STRING_TYPE], required: false,
                description: 'List of usernames'

    def resolve(ids: nil, usernames: nil)
      return ::UsersFinder.new(context[:current_user]).execute if ids.blank? && usernames.blank?

      ids_or_usernames = ids.map { |id| GitlabSchema.parse_gid(id, expected_type: ::User).model_id } if ids
      ids_or_usernames ||= usernames
      ids_or_usernames.map { |id| ::UserFinder.new(id).find_by_id_or_username }
    end

    def ready?(ids: nil, usernames: nil)
      return super if ids.blank? & usernames.blank?

      unless ids.present? ^ usernames.present?
        raise Gitlab::Graphql::Errors::ArgumentError, 'Provide either a list of usernames or ids'
      end

      super
    end
  end
end
