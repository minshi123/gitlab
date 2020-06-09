# frozen_string_literal: true

module Mutations
  module AlertManagement
    module Alerts
      class MarkTodo < Base
        graphql_name 'AlertMarkTodo'

        ArgumentError = ::Gitlab::Graphql::Errors::ArgumentError

        argument :todo_event,
                 GraphQL::STRING_TYPE,
                 required: true,
                 description: 'The todo event. supported: "add"',
                 prepare: ->(event, _ctx) do
                    raise ArgumentError, "Value #{event} for :todo_event not supported" unless event == 'add'
                 end

        def resolve(args)
          alert = authorized_find!(project_path: args[:project_path], iid: args[:iid])
          result = ::AlertManagement::Alerts::UpdateService.new(alert, current_user, todo_event: args[:todo_event]).execute

          prepare_response(result)
        end

        private

        def prepare_response(result)
          {
            alert: result.payload[:alert],
            errors: result.error? ? [result.message] : []
          }
        end
      end
    end
  end
end
