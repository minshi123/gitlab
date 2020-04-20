# frozen_string_literal: true

module API
  module Helpers
    module MeasurementHelpers
      def measurement_options(namespace)
        return {} unless Feature.enabled?(:measure_project_import_export, namespace)

        {
          measurement_logger: Gitlab::ImportExport::Project::Logger.build,
          measurement_enabled: true
        }
      end
    end
  end
end
