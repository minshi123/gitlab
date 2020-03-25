# frozen_string_literal: true

module Groups
  module Settings
    class IntegrationsController < Groups::ApplicationController
      def index
        @integrations = Project.first.find_or_initialize_services
      end
    end
  end
end
