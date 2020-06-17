# frozen_string_literal: true

module Resolvers
  class ComplianceFrameworksResolver < BaseResolver
    type EE::Types::ComplianceFrameworkType, null: true

    alias_method :project, :object

    def resolve(**args)
      [project.compliance_framework_setting].compact
    end
  end
end
