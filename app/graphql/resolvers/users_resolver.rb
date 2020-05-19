# frozen_string_literal: true

module Resolvers
  class UsersResolver < BaseResolver
    description 'Find users'

    argument    :id, GraphQL::STRING_TYPE, required: false,
                description: 'Username of user'

    def resolve(**args)
      User.where(username: 'user12299')
    end
  end
end
