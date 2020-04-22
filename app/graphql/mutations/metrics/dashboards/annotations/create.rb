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
          end
        end
      end
    end
  end
end
