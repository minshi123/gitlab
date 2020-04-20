# frozen_string_literal: true

module Packages
  module Composer
    class VersionParserService
      include ::Gitlab::Utils::StrongMemoize

      def initialize(tag_name: nil, branch_name: nil)
        @tag_name, @branch_name = tag_name, branch_name
      end

      def execute
        if @tag_name.present?
          @tag_name.match(composer_package_version_regex).captures[0]
        elsif @branch_name.present?
          branch_sufix_or_prefix(@branch_name.match(composer_package_version_regex))
        end
      end

      private

      def branch_sufix_or_prefix(match)
        if match
          if match.captures[1] == '.x'
            match.captures[0] + '-dev'
          else
            match.captures[0] + '.x-dev'
          end
        else
          "dev-#{@branch_name}"
        end
      end

      def composer_package_version_regex
        %r{^v?(\d+(\.(\d+|x))*(-.+)?)}.freeze
      end
    end
  end
end
