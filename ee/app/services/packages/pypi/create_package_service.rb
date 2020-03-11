# frozen_string_literal: true

module Packages
  module Pypi
    class CreatePackageService < BaseService
      def execute
        Packages::Package.transaction do
          ::Packages::CreatePackageFileService.new(created_package!, file_params).execute
        end
      end

      private

      def created_package!
        @created_package ||= project.packages.pypi.create!(
          name: params[:name],
          version: params[:version]
        )
      end

      def file_params
        {
          file: uploaded_package_file(:content),
          file_name: params[:name],
          file_sha256: params[:sha256_digest]
        }
      end
    end
  end
end
