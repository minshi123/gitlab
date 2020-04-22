# frozen_string_literal: true

module Types
  module AlertManagement
    class StatusEnum < BaseEnum
      graphql_name 'AlertManagementStatus'
      description 'Alert status values'

      value 'triggered', 'Triggered status'
      value 'acknowledged', 'Acknowledged status'
      value 'resolved', 'Resolved status'
      value 'ignored', 'Ignored status'
    end
  end
end
