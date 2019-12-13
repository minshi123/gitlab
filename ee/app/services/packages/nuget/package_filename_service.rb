# frozen_string_literal: true

module Packages
  module Nuget
    class PackageFilenameService
      attr_reader :package_name, :package_version

      def initialize(package_name, package_version)
        @package_name = package_name
        @package_version = package_version
      end

      def execute
        raise ArgumentError, 'invalid package name or version' unless valid_inputs?

        "#{package_name.downcase}.#{package_version.downcase}.nupkg"
      end

      private

      def valid_inputs?
        package_name.present? && package_version.present?
      end
    end
  end
end
