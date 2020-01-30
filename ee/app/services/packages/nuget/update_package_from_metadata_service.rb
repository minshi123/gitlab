# frozen_string_literal: true

module Packages
  module Nuget
    class UpdatePackageFromMetadataService
      include Gitlab::Utils::StrongMemoize

      InvalidMetadataError = Class.new(StandardError)

      attr_reader :package_file, :package_filepath

      def initialize(package_file)
        @package_file = package_file
      end

      def execute
        package_file.file.use_file do |file_path|
          @package_filepath = file_path

          raise InvalidMetadataError.new('package name and/or package version not found in metadata') unless valid_metadata?

          target_package = existing_package || package_file.package

          package_file.transaction do
            create_package_file_for(target_package)
            update_linked_package(target_package) unless existing_package
            cleanup!
          end
        end
      end

      private

      def create_package_file_for(package)
        File.open(package_filepath, 'r') do |file|
          file_params = package_file.attributes
                                    .slice('file_type', 'file_sha1', 'file_md5')
                                    .merge(
                                      file: file,
                                      size: package_file.file.size,
                                      file_name: package_filename
                                    )
          ::Packages::CreatePackageFileService.new(package, file_params).execute
        end
      end

      def cleanup!
        subject = existing_package ? package_file.package : package_file
        subject.destroy!
      end

      def valid_metadata?
        package_name.present? && package_version.present?
      end

      def update_linked_package(target_package)
        target_package.update!(
          name: package_name,
          version: package_version
        )
      end

      def existing_package
        strong_memoize(:existing_package) do
          package_file.project.packages
                              .nuget
                              .with_name(package_name)
                              .with_version(package_version)
                              .first
        end
      end

      def package_name
        metadata[:package_name]
      end

      def package_version
        metadata[:package_version]
      end

      def metadata
        strong_memoize(:metadata) do
          ::Packages::Nuget::MetadataExtractionService.new(package_filepath).execute
        end
      end

      def package_filename
        "#{package_name.downcase}.#{package_version.downcase}.nupkg"
      end
    end
  end
end
