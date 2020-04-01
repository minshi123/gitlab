# frozen_string_literal: true

module Resolvers
  module Projects
    class JiraImportsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      alias_method :project, :object

      def resolve(**args)
        return JiraImportState.none unless project&.jira_imports.present?

        authorize!(project)

        project.jira_imports
      end

      def authorized_resource?(project)
        Ability.allowed?(context[:current_user], :read_project, project)
      end
    end
  end
end
