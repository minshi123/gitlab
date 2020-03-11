# frozen_string_literal: true

module Packages
  module Pypi
    class CreatePackageService < BaseService
      include ::Gitlab::Utils::StrongMemoize

      def execute
        Packages::Package.transaction do
          delete_existing_package_file

          ::Packages::CreatePackageFileService.new(created_package, file_params).execute

          created_package.build_pypi_metadatum unless created_package.pypi_metadatum.present?
          created_package.pypi_metadatum.required_python = params[:requires_python]
          created_package.pypi_metadatum.save!
        end
      end

      private

      def delete_existing_package_file
        created_package.package_files.with_file_name(filename).destroy_all # rubocop: disable Cop/DestroyAll
      end

      def filename
        params[:file].original_filename
      end

      def created_package
        strong_memoize(:created_package) do
          project
            .packages
            .pypi
            .with_name(params[:name])
            .with_version(params[:version])
            .first_or_initialize
            .tap(&:save!)
        end
      end

      def file_params
        {
          file: params[:file],
          file_name: filename,
          file_md5: params[:md5_digest],
          file_sha256: params[:sha256_digest]
        }
      end
    end
  end
end
