# frozen_string_literal: true

module Mutations
  module Metrics
    module Dashboard
      module Annotations
        class Delete < BaseMutation
          graphql_name 'DeleteAnnotation'

          argument :id,
                  GraphQL::ID_TYPE,
                  required: true,
                  description: 'The global id of the annotation to destroy'

          def resolve(id:)
            annotation = authorized_find!(id: id)

            ::Metrics::Dashboard::Annotations::DeleteService.new(context[:current_user], annotation).execute

            {
              errors: errors_on_object(annotation)
            }
          end
        end
      end
    end
  end
end
