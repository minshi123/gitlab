# frozen_string_literal: true

module Resolvers
  module Vulnerabilities
    class ScannersResolver < VulnerabilitiesBaseResolver
      include Gitlab::Utils::StrongMemoize

      type Types::VulnerabilityScannerType, null: true

      def resolve(**args)
        return Vulnerabilities::Scanner.none unless vulnerable

        vulnerable
          .vulnerability_scanners
          .with_report_type
      end
    end
  end
end
