# frozen_string_literal: true

module EE
  module Resolvers
    module NamespaceProjectsResolver
      extend ActiveSupport::Concern

      prepended do
        argument :standalone_vulnerabilities_enabled, GraphQL::BOOLEAN_TYPE,
                 required: false,
                 default_value: false,
                 description: 'Returns only the projects which are using standalone vulnerabilities feature'
      end

      def resolve(include_subgroups:, standalone_vulnerabilities_enabled:)
        projects = super(include_subgroups: include_subgroups)
        standalone_vulnerabilities_enabled ? projects.with_standalone_vulnerabilities : projects
      end
    end
  end
end
