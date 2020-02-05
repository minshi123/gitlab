# frozen_string_literal: true

class ExpirationPolicyContainerRepositoryWorker
  include ApplicationWorker

  queue_namespace :container_repository
  feature_category :container_registry

  attr_reader :container_repository

  def perform(container_repository_id, params)
    @container_repository = ContainerRepository.find_by_id(container_repository_id)
    @params = params

    return false unless valid?

    Projects::ContainerRepository::CleanupTagsService
      .new(project, nil, params)
      .execute(container_repository)
  rescue ArgumentError => e
    Gitlab::ErrorTracking.track_exception(e, container_repository_id: container_repository.id)
  end

  private

  def valid?
    raise ArgumentError, 'not run by container_expiration_policy' unless valid_params

    valid_params && container_repository && project
  end

  def project
    container_repository&.project
  end

  def valid_params
    @params[:container_expiration_policy] == true
  end
end
