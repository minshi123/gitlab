# frozen_string_literal: true

module Packages
  module Composer
    class CreatePackageService < BaseService
      include ::Gitlab::Utils::StrongMemoize

      def execute
        created_package
      end

      private

      def created_package
        strong_memoize(:created_package) do
          project
            .packages
            .composer
            .safe_find_or_create_by!(name: package_name, version: package_version)
        end
      end

      def composer_json
        strong_memoize(:composer_json) do
          ::Packages::Composer::ComposerJsonService.new(project, target).execute
        end
      end

      def package_name
        composer_json['name']
      end

      def target
        (branch || tag).target
      end

      def branch
        params[:branch]
      end

      def tag
        params[:tag]
      end

      def package_version
        ::Packages::Composer::VersionParserService.new(tag_name: tag&.name, branch_name: branch&.name).execute
      end
    end
  end
end
