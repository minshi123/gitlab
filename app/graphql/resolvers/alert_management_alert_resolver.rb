# frozen_string_literal: true

module Resolvers
  class AlertManagementAlertResolver < BaseResolver
    argument :iid, GraphQL::STRING_TYPE,
              required: false,
              description: 'IID of the alert. For example, "1"'

    type Types::AlertManagement::AlertType, null: true

    def resolve(**args)
      return AlertManagement::Alert.none if object.nil?

      AlertManagement::AlertsFinder.new(context[:current_user], object, args).execute
    end
  end
end
