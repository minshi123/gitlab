# frozen_string_literal: true

module Types
  module Notes
    # This Type contains fields that are shared between objects that include either
    # the `ResolvableNote` or `ResolvableDiscussion` modules.
    module ResolvableNoteType
      include Types::BaseInterface

      field :resolved_by, Types::UserType,
            null: true,
            description: 'User who resolved the note or discussion',
            resolve: -> (resolvable, _args, _context) do
              next unless resolvable.resolved_by_id

              Gitlab::Graphql::Loaders::BatchModelLoader.new(User, resolvable.resolved_by_id).find
            end
      field :resolved, GraphQL::BOOLEAN_TYPE, null: false,
            description: 'Indicates if this note or discussion is resolved',
            method: :resolved?
      field :resolvable, GraphQL::BOOLEAN_TYPE, null: false,
            description: 'Indicates if this note or discussion can be resolved',
            method: :resolvable?
      field :resolved_at, Types::TimeType, null: true,
            description: "Timestamp of when the note or discussion was resolved"
    end
  end
end
