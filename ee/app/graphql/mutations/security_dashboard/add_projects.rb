# frozen_string_literal: true

module Mutations
  module SecurityDashboard
    class AddProjects < BaseMutation
      graphql_name 'AddProjectsToSecurityDashboard'

      field :invalid_project_ids, [GraphQL::ID_TYPE],
            null: true,
            description: 'IDs of projects that were not added to the Instance Security Dashboard'

      field :added_project_ids, [GraphQL::ID_TYPE],
            null: true,
            description: 'IDs of projects that were added to the Instance Security Dashboard'

      field :duplicated_project_ids, [GraphQL::ID_TYPE],
            null: true,
            description: 'IDs of projects that are already added to the Instance Security Dashboard'

      argument :project_ids, [GraphQL::ID_TYPE],
               required: true,
               description: 'IDs of projects to be added to Instance Security Dashboard'

      def resolve(project_ids:)
        return if current_user.blank?

        result = add_projects(project_ids.map(&method(:extract_project_id)))

        {
          invalid_project_ids: project_ids_to_gid(result.invalid_project_ids),
          added_project_ids: project_ids_to_gid(result.added_project_ids),
          duplicated_project_ids: project_ids_to_gid(result.duplicate_project_ids)
        }
      end

      private

      def extract_project_id(gid)
        return unless gid.present?

        GitlabSchema.parse_gid(gid, expected_type: ::Project).model_id
      end

      def add_projects(project_ids)
        Dashboard::Projects::CreateService.new(
          current_user,
          current_user.security_dashboard_projects,
          feature: :security_dashboard
        ).execute(project_ids)
      end

      def project_ids_to_gid(project_ids)
        project_ids
          .map { |id| Project.new(id: id) }
          .map(&GitlabSchema.method(:id_from_object))
      end
    end
  end
end
