# frozen_string_literal: true

module Mutations
  module Metrics
    module Dashboard
      module Annotations
        class Update < Base
          graphql_name 'UpdateAnnotation'

          argument :id,
                  GraphQL::ID_TYPE,
                  required: true,
                  description: 'The global id of the annotation to update'

          def resolve(args)
          end
        end
      end
    end
  end
end
