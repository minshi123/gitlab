# frozen_string_literal: true

module Types
  # rubocop: disable Graphql/AuthorizeTypes
  class CommitActionType < BaseInputObject
    argument :action, type: GraphQL::STRING_TYPE, required: true,
          description: 'The action to perform, create, delete, move, update, chmod'
    argument :file_path, type: GraphQL::STRING_TYPE, required: true,
          description: 'Full path to the file'
    argument :content, type: GraphQL::STRING_TYPE, required: false,
             description: 'Content of the file'
  end
  # rubocop: enable Graphql/AuthorizeTypes
end
