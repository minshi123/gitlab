# frozen_string_literal: true

module Resources
  class RevokeAccessTokenService
    attr_accessor :current_user, :access_token, :member

    def initialize(current_user, access_token, project)
      @current_user = current_user
      @access_token = access_token
      @member = project.project_member(access_token.user)
    end

    def execute
      revoke_access = ActiveRecord::Base.transaction do
        revoke && remove_member && migrate_to_ghost_user
      end

      if revoke_access
        success("Revoked project access token: #{@access_token.name}")
      else
        error("Failed to revoke access of project access token: #{@access_token.name}")
      end
    end

    private

    def revoke
      access_token.revoke!
    end

    def remove_member
      ::Members::DestroyService.new(current_user).execute(member)
    end

    def migrate_to_ghost_user
      ::Users::MigrateToGhostUserService.new(@access_token.user).execute
    end

    def error(message)
      ServiceResponse.error(message: message)
    end

    def success(message)
      ServiceResponse.success(message: message)
    end
  end
end
