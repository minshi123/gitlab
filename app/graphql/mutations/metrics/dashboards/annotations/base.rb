# frozen_string_literal: true

module Mutations
  module Metrics
    module Dashboards
      module Annotations
        class Base < BaseMutation
          field :annotation,
                Types::Metrics::Dashboards::AnnotationType,
                null: true,
                description: 'The annotation after mutation'

          private

          def find_object(id:)
            GitlabSchema.object_from_id(id)
          end

          def authorized_resource?(annotation)
            Ability.allowed?(context[:current_user], ability_for(annotation), annotation)
          end

          def ability_for(annotation)
            "#{ability_name}_#{annotation.to_ability_name}".to_sym
          end

          def ability_name
            raise NotImplementedError
          end
        end
      end
    end
  end
end
