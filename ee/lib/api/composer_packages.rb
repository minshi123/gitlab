# frozen_string_literal: true

# Php composer support (https://getcomposer.org/)
module API
  class ComposerPackages < Grape::API
    helpers ::API::Helpers::PackagesManagerClientsHelpers
    helpers ::API::Helpers::RelatedResourcesHelpers
    helpers ::API::Helpers::Packages::BasicAuthHelpers
    include ::API::Helpers::Packages::BasicAuthHelpers::Constants

    COMPOSER_ENDPOINT_REQUIREMENTS = {
      package_name: API::NO_SLASH_URL_PART_REGEX
    }.freeze

    default_format :json

    rescue_from ArgumentError do |e|
      render_api_error!(e.message, 400)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render_api_error!(e.message, 400)
    end

    before do
      require_packages_enabled!
    end

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end

    resource :group, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        unless ::Feature.enabled?(:composer_packages, user_group)
          not_found!
        end

        authorize_packages_feature!(user_group)
      end

      desc 'Composer packages endpoint at group level' do
        detail 'This feature was introduced in GitLab 13.0'
      end

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/packages.json' do
      end

      desc 'Composer packages endpoint at group level for packages list' do
        detail 'This feature was introduced in GitLab 13.0'
      end

      params do
        requires :sha, type: String, desc: 'Shasum of current json'
      end

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/p/:sha' do
      end

      desc 'Composer packages endpoint at group level for package versions metadata' do
        detail 'This feature was introduced in GitLab 13.0'
      end

      route_setting :authentication, job_token_allowed: true

      get ':id/-/packages/composer/*package_name', requirements: COMPOSER_ENDPOINT_REQUIREMENTS do
      end
    end
  end
end
