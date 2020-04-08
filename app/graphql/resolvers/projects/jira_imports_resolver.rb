# frozen_string_literal: true

module Resolvers
  module Projects
    class JiraImportsResolver < BaseResolver
      include Gitlab::Graphql::Authorize::AuthorizeResource

      alias_method :project, :object

      def resolve(**args)
        return JiraImportData.none unless project&.import_data.present?

        authorize!(project)

        project.import_data.becomes(JiraImportData).projects
      end

      def authorized_resource?(project)
        return false unless project.jira_issues_import_feature_flag_enabled?

        Ability.allowed?(context[:current_user], :admin_project, project)
      end
    end
  end
end
