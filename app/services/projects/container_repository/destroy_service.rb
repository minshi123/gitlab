# frozen_string_literal: true

module Projects
  module ContainerRepository
    class DestroyService < BaseService
      def execute(container_repository)
        return false unless can?(current_user, :update_container_image, project)

        # Delete tags outside of the transaction to avoid hitting an idle-in-transaction timeout
        container_repository.delete_tags!
        unless container_repository.destroy
          container_repository.delete_status = 'failed'
          container_repository.save!
        end
      end
    end
  end
end
