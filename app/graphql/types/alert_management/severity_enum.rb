# frozen_string_literal: true

module Types
  module AlertManagement
    class SeverityEnum < BaseEnum
      graphql_name 'AlertManagementSeverity'
      description 'Alert severity values'

      value 'critical', 'Critical severity'
      value 'high', 'High severity'
      value 'medium', 'Medium severity'
      value 'low', 'Low severity'
      value 'info', 'Info severity'
      value 'unknown', 'Unknown severity'
    end
  end
end
