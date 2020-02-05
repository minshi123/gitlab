# frozen_string_literal: true

module Projects
  module IncidentManagement
    module Settings
      def incident_management_available?
        project.feature_available?(:incident_management)
      end

      def incident_management_setting
        strong_memoize(:incident_management_setting) do
          project.incident_management_setting ||
            project.build_incident_management_setting
        end
      end

      def send_email?
        return unless incident_management_available?

        incident_management_setting.send_email
      end

      def process_issues?
        return unless incident_management_available?

        incident_management_setting.create_issue?
      end
    end
  end
end
