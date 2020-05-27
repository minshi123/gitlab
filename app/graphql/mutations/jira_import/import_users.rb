# frozen_string_literal: true

module Mutations
  module JiraImport
    class ImportUsers < BaseMutation
      include Mutations::ResolvesProject

      graphql_name 'JiraImportUsers'

      argument :project_path, GraphQL::ID_TYPE,
               required: true,
               description: 'The project to import the Jira project into'
      argument :start_at, GraphQL::INT_TYPE,
               required: true,
               description: 'The index of the record the importt should started at, default 0'

      def resolve
        project = find_project!(project_path: project_path)

        raise_resource_not_available_error! unless project

        service_response = ::JiraImport::UsersImporter.new(project, start_at).execute
        errors = service_response.error? ? [service_response.message] : []

        {
          jira_users: service_response.payload,
          errors: errors
        }
      end

      private

      def find_project!(project_path:)
        return unless project_path.present?

        authorized_find!(full_path: project_path)
      end

      def find_object(full_path:)
        resolve_project(full_path: full_path)
      end

      def authorized_resource?(project)
        Ability.allowed?(context[:current_user], :admin_project, project)
      end
    end
  end
end
