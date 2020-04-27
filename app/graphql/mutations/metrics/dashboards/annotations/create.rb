# frozen_string_literal: true

module Mutations
  module Metrics
    module Dashboard
      module Annotations
        class Create < BaseMutation
          graphql_name 'CreateAnnotation'

          field :annotation,
                Types::Metrics::Dashboards::AnnotationType,
                null: true,
                description: 'The annotation after mutation'

          def resolve(args)
            ::Metrics::Dashboard::Annotations::CreateService.new(context[:current_user], args).execute
          end
        end
      end
    end
  end
end
