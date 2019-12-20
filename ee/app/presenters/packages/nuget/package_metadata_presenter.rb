# frozen_string_literal: true

module Packages
  module Nuget
    class PackageMetadataPresenter
      include API::Helpers::RelatedResourcesHelpers

      attr_reader :package

      def initialize(package)
        raise ArgumentError unless package.npm?

        @package = package
      end

      def json_url
      end

      def nuget_package_url
      end

      def catalog_entry
        {
          package_name: package.name,
          package_version: package.version,
          json_url: json_url,
          nuget_package_url: nuget_package_url,
          authors: '',
          dependencies: [],
          summary: ''
        }
      end
    end
  end
end
