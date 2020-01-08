# frozen_string_literal: true

module Packages
  module Nuget
    class PackagesMetadataPresenter
      include API::Helpers::RelatedResourcesHelpers
      include API::Helpers::Packages::Nuget::MetadataPresenterHelpers

      attr_reader :packages

      COUNT = 1.freeze

      def initialize(packages)
        @packages = packages
      end

      def count
        COUNT
      end

      def items
        [summary]
      end

      private

      def summary
        {
          json_url: json_url,
          lower_version: lower_version,
          upper_version: upper_version,
          packages_count: packages.count,
          packages: packages.map { |pkg| catalog_entry_for(pkg) }
        }
      end

      def json_url
        json_url_for(packages.first)
      end

      def lower_version
        sorted_versions.first
      end

      def upper_version
        sorted_versions.last
      end

      def sorted_versions
        versions = packages.map(&:version).compact
        VersionSorter.sort(versions)
      end
    end
  end
end
