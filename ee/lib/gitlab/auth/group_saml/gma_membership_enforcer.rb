# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class GmaMembershipEnforcer
        def initialize(project)
          @project = project
        end

        def can_add_user?(user)
          can_add_user_to_main_project = check_group_membership(user, project)
          can_add_user_to_source_project = project.forked? ? check_group_membership(user, project.forked_from_project) : true

          can_add_user_to_main_project && can_add_user_to_source_project
        end

        private

        attr_reader :project

        def check_group_membership(user, given_project)
          group = project_root_group(given_project)
          return true unless ::Feature.enabled?(:group_managed_accounts, group)
          return true unless group&.enforced_group_managed_accounts?

          group == user.managing_group
        end

        def project_root_group(project)
          project&.root_ancestor
        end
      end
    end
  end
end
