# frozen_string_literal: true

module API
  class DependencyProxy < Grape::API
    before { authenticated_as_admin! }

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Deletes all dependency_proxy_blobs for a group' do
        detail 'This feature was introduced in GitLab 12.10'
      end
      delete 'dependency_proxy/cache' do
        user_group.dependency_proxy_blobs.delete_all
      end
    end
  end
end
