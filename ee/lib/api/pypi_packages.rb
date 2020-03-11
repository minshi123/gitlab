# frozen_string_literal: true

# PyPI Package Manager Client API
#
# These API endpoints are not meant to be consumed directly by users. They are
# called by the PyPI package manager client when users run commands
# like `pip install` or `twine upload`.
module API
  class PypiPackages < Grape::API
    helpers ::API::Helpers::PackagesManagerClientsHelpers
    helpers ::API::Helpers::RelatedResourcesHelpers
    helpers ::API::Helpers::Packages::BasicAuthHelpers
    include ::API::Helpers::Packages::BasicAuthHelpers::Constants
    include ::API::Helpers::PackagesManagerClientsHelpers::Constants

    default_format :json

    rescue_from ArgumentError do |e|
      render_api_error!(e.message, 400)
    end

    helpers do
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
      end
    end

    before do
      require_packages_enabled!
    end

    params do
      requires :id, type: String, desc: 'The ID of a project', regexp: POSITIVE_INTEGER_REGEX
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      before do
        authorize_packages_feature!(authorized_user_project)
      end

      namespace ':id/packages/pypi' do
        desc 'The PyPi package download endpoint' do
          detail 'This feature was introduced in GitLab 12.10'
        end

        params do
          requires :file_identifier, type: String, desc: 'The PyPi package file identifier', regexp: API::NO_SLASH_URL_PART_REGEX
        end

        get 'files/*file_identifier', :txt do
          authorize_read_package!(authorized_user_project)

          if params[:file_identifier] != 'sample_project-1.0.0-py3-none-any'
            not_found!
          end

          content_type "application/octet-stream"
          env['api.format'] = :binary
          body File.read(Rails.root.join('spec', 'fixtures', 'sample_project-1.0.0-py3-none-any.whl'))
        end

        desc 'The PyPi Simple Endpoint' do
          detail 'This feature was introduced in GitLab 12.10'
        end

        params do
          requires :package_name, type: String, desc: 'The PyPi package name', regexp: API::NO_SLASH_URL_PART_REGEX
        end

        get 'simple/*package_name', format: :txt do
          authorize_read_package!(authorized_user_project)

          if params[:package_name] != 'sample-project'
            not_found!
          end

          package = Packages::Package.new(name: 'sample-project', version: '1.0.0')
          presenter = ::Packages::Pypi::PackagePresenter.new([package], authorized_user_project)

          content_type "text/html; charset=utf-8"
          env['api.format'] = :binary
          body presenter.body
        end

        desc 'The PyPi Package upload endpoint' do
          detail 'This feature was introduced in GitLab 12.10'
        end

        params do
          use :workhorse_upload_params
        end

        post do
          authorize_upload!(authorized_user_project)

          # file_params = params.merge(
          #   file: uploaded_package_file(:content),
          #   file_name: params[:name],
          #   sha256: params[:sha256_digest],
          #   version: params[:version],
          #   requires_python: params[:requires_python]
          # )

          created!
        rescue ObjectStorage::RemoteStoreError => e
          Gitlab::ErrorTracking.track_exception(e, extra: { file_name: params[:name], project_id: authorized_user_project.id })

          forbidden!
        end

        post 'authorize' do
          authorize_workhorse!(subject: authorized_user_project, has_length: false)
        end
      end
    end
  end
end
