# frozen_string_literal: true

# Display package version data acording to PyPi
# Simple API: https://warehouse.pypa.io/api-reference/legacy/#simple-project-api
# FIXME: This is a prototype only and is meant only as a proof of concept
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
        # TODO: package name this format conversion (- becomes _). (What else?)
        # TODO: sha256 needs to be collected and returned as pip validates it
        # TODO: retrieve required_python version
        @packages.map do |package|
          link = "#{package.name.tr('-', '_')}-#{package.version}-py3-none-any.whl"
          required_python = "&gt;=3.6"
          sha256 = "0c77d584df6ddc378eb89575a2432f76f1b64e244036bc8e1f8fb73acffddb5b"
          url = expose_url(api_v4_projects_packages_pypi_files_file_identifier_path(id: @project.id, file_identifier: link))
          url = "#{url}#sha256=#{sha256}"

          "<a href=\"#{url}\" data-requires-python=\"#{required_python}\">#{link}</a><br>"
        end.join
      end

      def name
        @packages.first.name
      end
    end
  end
end
