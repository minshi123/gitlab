# frozen_string_literal: true

module Mutations
  module SecurityDashboard
    class RemoveProject < BaseMutation
      graphql_name 'RemoveProjectFromSecurityDashboard'

      field :project_id, GraphQL::ID_TYPE,
            null: true,
            description: 'ID of projects that was removed from the Instance Security Dashboard'

      argument :project_id, GraphQL::ID_TYPE,
               required: true,
               description: 'ID of projects to be removed from Instance Security Dashboard'

      def resolve(project_id:)
        return if current_user.blank?

        result = remove_project(extract_project_id(project_id))

        {
          project_id: result.zero? ? nil : project_id
        }
      end

      private

      def extract_project_id(gid)
        return unless gid.present?

        GitlabSchema.parse_gid(gid, expected_type: ::Project).model_id
      end

      def remove_project(project_id)
        current_user
          .users_security_dashboard_projects
          .delete_by_project_id(project_id)
      end
    end
  end
end
