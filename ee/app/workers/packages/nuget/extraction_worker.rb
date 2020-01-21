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

        package_file.transaction do
          package_file.update!(package_file_params)

          if existing_package_id
            package_to_destroy = package_from_package_file
            package_file.update_column(:package_id, existing_package_id)
            package_to_destroy.destroy!
          else
            package_from_package_file.update!(package_params)
          end
        end
      end

      private

      def valid_inputs?
        package_file && package_params.any? && package_file_params.any?
      end

      def existing_package_id
        project_from_package_file.packages
                                 .nuget
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
        empty_hash_if_all_values_blank(
          name: package_name_from_metadata,
          version: package_version_from_metadata
        )
      end

      def package_file_params
        empty_hash_if_all_values_blank(file_name: filename_from_metadata)
      end

      def package_name_from_metadata
        metadata[:package_name]
      end

      def package_version_from_metadata
        metadata[:package_version]
      end

      def metadata
        strong_memoize(:metadata) do
          ::Packages::Nuget::MetadataExtractionService.new(package_file_id).execute
        rescue ArgumentError
          # invalid package archive, can't read metadata from it
          EMPTY_HASH
        end
      end

      def filename_from_metadata
        ::Packages::Nuget::PackageFilenameService.new(
          package_name_from_metadata,
          package_version_from_metadata
        ).execute
      end

      def empty_hash_if_all_values_blank(hash)
        return EMPTY_HASH if hash.values.all?(&:blank?)

        hash
      end
    end
  end
end
