# frozen_string_literal: true

module Gitlab
  module SPDX
    class Catalogue
      include Enumerable

      OFFLINE_CATALOGUE = 'vendor/spdx.json'

      def initialize(catalogue = {})
        @catalogue = catalogue
      end

      def version
        catalogue[:licenseListVersion]
      end

      def each
        licenses.each do |license|
          yield license if license.id.present?
        end
      end

      def self.latest
        if offline_env? & Feature.enabled?(:offline_spdx_catalogue)
          new(offline_catalogue)
        else
          CatalogueGateway.new.fetch
        end
      end

      private

      attr_reader :catalogue

      def licenses
        @licenses ||= catalogue.fetch(:licenses, []).map { |x| map_from(x) }
      end

      def map_from(license_hash)
        ::Gitlab::SPDX::License.new(
          id: license_hash[:licenseId],
          name: license_hash[:name],
          deprecated: license_hash[:isDeprecatedLicenseId]
        )
      end

      def offline_catalogue
        Gitlab::JSON.parse(Rails.root.join(OFFLINE_CATALOGUE))
      end
    end
  end
end
