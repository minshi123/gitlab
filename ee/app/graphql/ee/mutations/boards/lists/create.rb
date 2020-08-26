# frozen_string_literal: true

module EE
  module Mutations
    module Boards
      module Lists
        module Create
          extend ActiveSupport::Concern
          extend ::Gitlab::Utils::Override

          prepended do
            argument :milestone_id, GraphQL::ID_TYPE,
                     required: false,
                     description: 'Global ID of an existing milestone'
            argument :assignee_id, GraphQL::ID_TYPE,
                     required: false,
                     description: 'Global ID of an assignee'
          end

          private

          override :authorize_list_type_resource!
          def authorize_list_type_resource!(board, params)
            super

            if params[:milestone_id]
              milestones = ::Boards::MilestonesFinder.new(board, current_user).execute

              unless milestones.find_by(id: params[:milestone_id])
                raise Gitlab::Graphql::Errors::ArgumentError, 'Milestone not found!'
              end
            end

            if params[:assignee_id]
              users = ::Boards::UsersFinder.new(board, current_user).execute

              unless users.find_by(user_id: params[:assignee_id])
                raise Gitlab::Graphql::Errors::ArgumentError, 'User not found!'
              end
            end
          end

          override :create_list_params
          def create_list_params(args)
            params = super

            if params[:milestone_id]
              params[:milestone_id] = GitlabSchema.parse_gid(params[:milestone_id], expected_type: ::Milestone).model_id
            end

            if params[:assignee_id]
              params[:assignee_id] = GitlabSchema.parse_gid(params[:assignee_id], expected_type: ::User).model_id
            end

            params
          end

          override :mutually_exclusive_args
          def mutually_exclusive_args
            super + [:milestone_id, :assignee_id]
          end
        end
      end
    end
  end
end
