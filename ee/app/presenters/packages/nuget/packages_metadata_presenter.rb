# frozen_string_literal: true

module Packages
  module Nuget
    class PackagesMetadataPresenter
      include API::Helpers::RelatedResourcesHelpers

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
          packages: packages.map { |pkg| ::Packages::Nuget::PackageMetadataPresenter.new(package) }
        }
      end

      def json_url
      end

      def lower_version
      end

      def upper_version
      end
    end
  end
end
