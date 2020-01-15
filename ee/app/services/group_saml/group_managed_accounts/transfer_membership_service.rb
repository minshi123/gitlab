# frozen_string_literal: true

module GroupSaml
  module GroupManagedAccounts
    class TransferMembershipService
      attr_reader :group, :current_user, :oauth_data, :session

      def initialize(current_user, group, session)
        @current_user = current_user
        @group = group
        @oauth_data = session['oauth_data']
        @session = session
      end

      def execute
        ActiveRecord::Base.transaction do
          current_user.managing_group = group
          current_user.password = nil
          current_user.password_confirmation = nil

          if destroy_non_gma_identities && leave_non_gma_groups && leave_non_gma_projects && current_user.save
            identity_linker = Gitlab::Auth::GroupSaml::IdentityLinker.new(current_user, oauth_data, session, group.saml_provider)
            identity_linker.link
          end

          current_user.persisted? && !identity_linker.failed?
        end
      end

      private

      def destroy_non_gma_identities
        current_user.identities.all? do |identity|
          Identity::DestroyService.new(identity).execute
          identity.destroyed?
        end
      end

      def leave_non_gma_groups
        current_user.groups.all? do |group|
          member = group.members_and_requesters.find_by!(user_id: current_user.id)
          Members::DestroyService.new(current_user).execute(member)
          member.destroyed?
        end
      end

      def leave_non_gma_projects
        current_user.projects.all? do |project|
          member = project.members_and_requesters.find_by!(user_id: current_user.id)
          Members::DestroyService.new(current_user).execute(member)
          member.destroyed?
        end
      end
    end
  end
end
