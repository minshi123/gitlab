# frozen_string_literal: true

# Display package version data acording to PyPi
# Simple API: https://warehouse.pypa.io/api-reference/legacy/#simple-project-api
module Packages
  module Pypi
    class PackagePresenter
      include API::Helpers::RelatedResourcesHelpers

      def initialize(packages, project)
        @packages = packages
        @project = project
      end

      def body
        <<-HTML
        <!DOCTYPE html>
        <html>
          <head>
            <title>Links for #{name}</title>
          </head>
          <body>
            <h1>Links for #{name}</h1>
            #{links}
          </body>
        </html>
        HTML
      end

      private

      def links
        refs = []

        @packages.map do |package|
          package.package_files.each do |file|
            required_python = package.pypi_metadatum.required_python

            url = expose_url(
              api_v4_projects_packages_pypi_files_path(
                id: @project.id,
                file_identifier: file.file_name
              )
            ) + "#sha256=#{file.file_sha256}"

            refs << "<a href=\"#{url}\" data-requires-python=\"#{required_python}\">#{file.file_name}</a><br>"
          end
        end

        refs.join
      end

      def name
        @packages.first.name
      end
    end
  end
end
