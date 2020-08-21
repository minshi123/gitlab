# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    prepend Gitlab::Graphql::Present
    prepend Gitlab::Graphql::ExposePermissions
    prepend Gitlab::Graphql::MarkdownField

    field_class Types::BaseField

    # All graphql fields exposing an id, should expose a global id.
    def id
      GitlabSchema.id_from_object(object)
    end

    def self.authorized?(object, context)
      # The accepts definition defines this method
      Array.wrap(authorize).all? { |ability| Ability.allowed?(current_user, ability, object) }
    end

    def current_user
      context[:current_user]
    end
  end
end
