# frozen_string_literal: true

module API
  module Helpers
    module Packages
      module Nuget
        module MetadataPresenterHelpers
          include ::API::Helpers::PackagesHelpers

          private

          def json_url_for(package)
            path = api_v4_projects_packages_nuget_metadata_path(
              id: package.project_id,
              package_name: package.name,
              package_version: package.version,
              format: '.json'
            )

            expose_url(path)
          end

          def archive_url_for(package)
            filename_service = ::Packages::Nuget::PackageFilenameService.new(package.name, package.version)
            path = api_v4_projects_packages_nuget_download_path(
              id: package.project_id,
              package_name: package.name,
              package_version: package.version,
              package_filename: filename_service.execute
            )
            expose_url(path)
          end

          def catalog_entry_for(package)
            {
              package_name: package.name,
              package_version: package.version,
              json_url: json_url_for(package),
              archive_url: archive_url_for(package),
              authors: '',
              dependencies: [],
              summary: ''
            }
          end
        end
      end
    end
  end
end
