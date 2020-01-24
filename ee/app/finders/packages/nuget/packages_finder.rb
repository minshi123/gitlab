# frozen_string_literal: true
module Packages
  module Nuget
    class PackagesFinder
      attr_reader :project, :package_name, :package_version

      delegate :first, to: :execute

      def initialize(project:, package_name:, package_version: nil)
        @project = project
        @package_name = package_name
        @package_version = package_version
      end

      def execute
        packages.has_version
                .processed
                .preload_files
      end

      private

      def packages
        result = project.packages
                        .nuget
                        .with_name(package_name)
        result = result.with_version(package_version) if package_version.present?
        result
      end
    end
  end
end
