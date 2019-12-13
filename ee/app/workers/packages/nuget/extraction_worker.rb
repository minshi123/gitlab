# frozen_string_literal: true

module Packages
  module Nuget
    class ExtractionWorker
      include ApplicationWorker
      include Gitlab::Utils::StrongMemoize

      queue_namespace :package_repositories
      feature_category :package_registry

      attr_reader :package_file_id

      EMPTY_HASH = {}.freeze

      def perform(package_file_id)
        @package_file_id = package_file_id

        return unless valid_inputs?

        package_file.update!(package_file_params)

        if existing_package_id
          package_to_destroy = package_from_package_file
          package_file.update_column(:package_id, existing_package_id)
          package_to_destroy.destroy!
        else
          package_from_package_file.update!(package_params)
        end
      end

      private

      def valid_inputs?
        package_file && package_params.any? && package_file_params.any?
      end

      def existing_package_id
        project_from_package_file.packages
                                 .with_name(package_name_from_metadata)
                                 .with_version(package_version_from_metadata)
                                 .pluck_primary_key
                                 .first
      end

      def package_file
        strong_memoize(:package_file) do
          ::Packages::PackageFile.id_in(package_file_id)
                                 .first
        end
      end

      def package_from_package_file
        package_file.package
      end

      def project_from_package_file
        package_from_package_file.project
      end

      def package_params
        empty_hash_if_blank_values(
          name: package_name_from_metadata,
          version: package_version_from_metadata
        )
      end

      def package_file_params
        empty_hash_if_blank_values(file_name: filename_from_metadata)
      end

      def metadata
        strong_memoize(:metadata) do
          metadata_extraction_service.execute
        rescue ArgumentError
          EMPTY_HASH
        end
      end

      def package_name_from_metadata
        metadata[:package_name]
      end

      def package_version_from_metadata
        metadata[:package_version]
      end

      def filename_from_metadata
        package_filename_service.execute

      rescue ArgumentError
        nil
      end

      def empty_hash_if_blank_values(hash)
        return EMPTY_HASH if hash.values.all?(&:blank?)

        hash
      end

      def metadata_extraction_service
        ::Packages::Nuget::MetadataExtractionService.new(package_file_id)
      end

      def package_filename_service
        ::Packages::Nuget::PackageFilenameService.new(package_name_from_metadata, package_version_from_metadata)
      end
    end
  end
end
