# frozen_string_literal: true

module AlertManagement
  class AlertsFinder
    attr_reader :current_user, :project, :params

    def initialize(current_user, project, params)
      @current_user = current_user
      @project = project
      @params = params
    end

    def execute
      return AlertManagement::Alert.none unless authorized?

      collection = project.alert_management_alerts
      by_iid(collection)
    end

    private

    def by_iid(collection)
      return collection unless params[:iid]

      found = collection.find_by_iid(params[:iid])
      found ? [found] : AlertManagement::Alert.none
    end

    def authorized?
      Ability.allowed?(current_user, :read_alert_management_alerts, project)
    end
  end
end
