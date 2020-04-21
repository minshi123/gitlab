# frozen_string_literal: true

module Resolvers
  class SecurityDashboardResolver < BaseResolver
    type ::Types::SecurityDashboardType, null: true

    def resolve(**args)
      return unless current_user.present?

      InstanceSecurityDashboard.new(current_user)
    end
  end
end
