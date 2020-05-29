# frozen_string_literal: true

module Packages
  module Nuget
    module PresenterHelpers
      include ::API::Helpers::RelatedResourcesHelpers

      BLANK_STRING = ''
      PACKAGE_DEPENDENCY_GROUP = 'PackageDependencyGroup'
      PACKAGE_DEPENDENCY = 'PackageDependency'

      private

      def json_url_for(package)
        path = api_v4_projects_packages_nuget_metadata_package_name_package_version_path(
          {
            id: package.project_id,
            package_name: package.name,
            package_version: package.version,
            format: '.json'
          },
          true
        )

        expose_url(path)
      end

      def archive_url_for(package)
        path = api_v4_projects_packages_nuget_download_package_name_package_version_package_filename_path(
          {
            id: package.project_id,
            package_name: package.name,
            package_version: package.version,
            package_filename: package.package_files.last&.file_name
          },
          true
        )

        expose_url(path)
      end

      def catalog_entry_for(package)
        {
          json_url: json_url_for(package),
          authors: BLANK_STRING,
          dependency_groups: dependency_groups_for(package),
          package_name: package.name,
          package_version: package.version,
          archive_url: archive_url_for(package),
          summary: BLANK_STRING,
          tags: tags_for(package),
          metadatum: metadatum_for(package)
        }
      end

      def dependency_groups_for(package)
        base_id = "#{json_url_for(package)}#dependencyGroup"
        package
          .dependency_links
          .preload_dependency
          .preload_nuget_metadatum
          .group_by { |e| e.nuget_metadatum&.target_framework }.map do |target_framework, dependency_links|
            id = id_for_target_framework(base_id, target_framework)
            {
              id: id,
              type: PACKAGE_DEPENDENCY_GROUP,
              target_framework: target_framework,
              dependencies: dependencies_for(id, dependency_links)
            }.compact
          end
      end

      def dependencies_for(id, dependency_links)
        dependency_links.map do |dependency_link|
          dependency = dependency_link.dependency
          {
            id: "#{id}/#{dependency.name.downcase}",
            type: PACKAGE_DEPENDENCY,
            range: dependency.version_pattern
          }
        end
      end

      def id_for_target_framework(base_id, target_framework)
        target_framework.blank? ? base_id : "#{base_id}/#{target_framework.downcase}"
      end

      def metadatum_for(package)
        metadatum = package.nuget_metadatum
        return {} unless metadatum

        metadatum.slice(:project_url, :license_url, :icon_url)
                  .compact
      end

      def base_path_for(package)
        api_v4_projects_packages_nuget_path(id: package.project_id)
      end

      def tags_for(package)
        package.tag_names.join(::Packages::Tag::NUGET_TAGS_SEPARATOR)
      end
    end
  end
end
