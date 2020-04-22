# frozen_string_literal: true

module Types
  module AlertManagement
    class AlertType < BaseObject
      graphql_name 'AlertManagementAlert'
      description 'Describes an alert from the projects Alert Management.'

      authorize :read_alert_management_alerts

      # TODO
      # present_using AlertManagementAlertPresenter

      field :iid,
            GraphQL::ID_TYPE,
            null: false,
            description: 'Internal ID of the alert'

      field :title,
            GraphQL::STRING_TYPE,
            null: false,
            description: 'Title of the alert'

      field :severity,
            AlertManagement::SeverityEnum,
            null: false,
            description: 'Severity of the alert'

      field :status,
            AlertManagement::StatusEnum,
            null: false,
            description: 'Status of the alert'

      field :started_at,
            Types::TimeType,
            null: false,
            description: 'Timestamp the alert was raised'

      field :ended_at,
            Types::TimeType,
            null: true,
            description: 'Timestamp the alert ended'

      field :event_count,
            GraphQL::INT_TYPE,
            null: false,
            description: 'Number of events of this alert',
            method: :events
    end
  end
end
