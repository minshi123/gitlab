# frozen_string_literal: true

module AlertManagement
  class MatchingAlertsFinder < AlertsFinder
    def execute
      return AlertManagement::Alert.none unless authorized?

      @collection = project.alert_management_alerts

      by_full_payload.presence ||
      by_detailed_attributes.presence ||
      by_title_description.presence ||
      collection.none
    end

    private

    attr_reader :current_user, :project, :params, :collection

    PAYLOAD_PARAMS_TO_EXCLUDE = %w(start_time)
    DETAILED_ATTRIBUTES = %w(service monitoring_tool title description)
    TITLE_DESCRIPTION_ATTRIBUTES = %w(title description)

    def by_full_payload
      # Compare payload other than start time
      params_to_test = params.excluding(PAYLOAD_PARAMS_TO_EXCLUDE)

      return if (params_to_test.keys.map(&:to_s) - DETAILED_ATTRIBUTES).empty?

      collection.for_payload_containing(params_to_test)
    end

    def by_detailed_attributes
      params_to_test = generate_query(DETAILED_ATTRIBUTES)

      collection.where(params_to_test)
    end

    def by_title_description
      params_to_test = generate_query(TITLE_DESCRIPTION_ATTRIBUTES)

      collection.where(params_to_test)
    end

    def generate_query(attribute_keys)
      Hash[ *attribute_keys.collect { |k| [k, params[k]] }.flatten ]
    end
  end
end
