# frozen_string_literal: true

# PyPI Package Manager Client API
#
# These API endpoints are not meant to be consumed directly by users. They are
# called by the PyPI package manager client when users run commands
# like `pip install` or `twine upload`.
module API
  class PypiPackages < Grape::API
    helpers ::API::Helpers::PackagesManagerClientsHelpers

    AUTHORIZATION_HEADER = 'Authorization'
    AUTHENTICATE_REALM_HEADER = 'Www-Authenticate: Basic realm'
    AUTHENTICATE_REALM_NAME = 'GitLab Nuget Package Registry'
    POSITIVE_INTEGER_REGEX = %r{\A[1-9]\d*\z}.freeze
    NON_NEGATIVE_INTEGER_REGEX = %r{\A0|[1-9]\d*\z}.freeze

    PACKAGE_FILENAME = 'package.nupkg'

    default_format :json

    rescue_from ArgumentError do |e|
      render_api_error!(e.message, 400)
    end

    helpers do
      def find_personal_access_token
        find_personal_access_token_from_http_basic_auth
      end

      def authorized_user_project
        @authorized_user_project ||= authorized_project_find!(params[:id])
      end

      def authorized_project_find!(id)
        project = find_project(id)

        unless project && can?(current_user, :read_project, project)
          return unauthorized_or! { not_found! }
        end

        project
      end

      def authorize!(action, subject = :global, reason = nil)
        return if can?(current_user, action, subject)

        unauthorized_or! { forbidden!(reason) }
      end

      def unauthorized_or!
        current_user ? yield : unauthorized_with_header!
      end

      def unauthorized_with_header!
        header(AUTHENTICATE_REALM_HEADER, AUTHENTICATE_REALM_NAME)
        unauthorized!
      end

      def find_packages
        packages = package_finder.execute

        not_found!('Packages') unless packages.exists?

        packages
      end

      def find_package
        package = package_finder(package_version: params[:package_version]).execute
                                                                           .first

        not_found!('Package') unless package

        package
      end

      def package_finder(finder_params = {})
        ::Packages::Nuget::PackageFinder.new(
          authorized_user_project,
          finder_params.merge(package_name: params[:package_name])
        )
      end
    end

    before do
      require_packages_enabled!
    end

    namespace 'packages/pypi' do
      desc 'The PyPi package download endpoint' do
        detail 'This feature was introduced in GitLab 12.10'
      end

      params do
        requires :file_identifier, type: String, desc: 'The PyPi package file identifier', regexp: API::NO_SLASH_URL_PART_REGEX
      end

      get '*file_identifier' do
        authorize_read_package!(authorized_user_project)
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a project', regexp: POSITIVE_INTEGER_REGEX
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!(authorized_user_project)
      end

      namespace ':id/packages/pypi' do
        desc 'The PyPi Simple Endpoint' do
          detail 'This feature was introduced in GitLab 12.10'
        end

        params do
          requires :package_name, type: String, desc: 'The PyPi package name', regexp: API::NO_SLASH_URL_PART_REGEX
        end

        get 'simple/*package_name', format: :json do
          authorize_read_package!(authorized_user_project)
        end

        desc 'The PyPi Package upload endpoint' do
          detail 'This feature was introduced in GitLab 12.10'
        end

        params do
          use :workhorse_upload_params
        end

        post do
          authorize_upload!(authorized_user_project)

          file_params = params.merge(
            file: uploaded_package_file(:package),
            file_name: PACKAGE_FILENAME
          )

          package = ::Packages::Nuget::CreatePackageService.new(authorized_user_project, current_user)
                                                           .execute

          package_file = ::Packages::CreatePackageFileService.new(package, file_params)
                                                             .execute

          track_event('push_package')

          created!
        rescue ObjectStorage::RemoteStoreError => e
          Gitlab::ErrorTracking.track_exception(e, extra: { file_name: params[:file_name], project_id: authorized_user_project.id })

          forbidden!
        end

        put 'authorize' do
          authorize_workhorse!(subject: authorized_user_project, has_length: false)
        end
      end
    end
  end
end
