# frozen_string_literal: true

module API
  module Helpers
    module Packages
      module Nuget
        module MetadataPresenterHelpers
          include ::API::Helpers::PackagesHelpers

          BLANK_STRING = ''
          EMPTY_ARRAY = [].freeze

          private

          def json_url_for(package)
            # TODO NUGET: use grape api helper when wildcard support is available.
            path = "#{base_path_for(package)}/metadata/#{package.name}/#{package.version}.json"

            expose_url(path)
          end

          def archive_url_for(package)
            filename_service = ::Packages::Nuget::PackageFilenameService.new(package.name, package.version)
            # TODO NUGET: use grape api helper when wildcard support is available.
            path = "#{base_path_for(package)}/download/#{package.name}/#{package.version}/#{filename_service.execute}"

            expose_url(path)
          end

          def catalog_entry_for(package)
            {
              json_url: json_url_for(package),
              authors: BLANK_STRING,
              dependencies: EMPTY_ARRAY,
              package_name: package.name,
              package_version: package.version,
              archive_url: archive_url_for(package),
              summary: BLANK_STRING
            }
          end

          def base_path_for(package)
            api_v4_projects_packages_nuget_path(id: package.project.id)
          end
        end
      end
    end
  end
end
