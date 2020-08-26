# frozen_string_literal: true

# Interface to expose a pending Todo for the current_user on the object.
module Types
  module PendingTodo
    include BaseInterface

    field_class Types::BaseField

    field :pending_todo, Types::TodoType,
          description: 'Pending todo for the current user',
          null: true

    def pending_todo
      BatchLoader::GraphQL.for(object.id).batch(key: object.class.name) do |ids, loader, args|
        target_type = args[:key]

        current_user.todos.pending.for_type(target_type).for_target(ids).each do |todo|
          loader.call(todo.target_id, todo)
        end
      end
    end
  end
end
