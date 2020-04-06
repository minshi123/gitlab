# frozen_string_literal: true

class Prometheus::CreateDefaultAlertsWorker
  include ApplicationWorker

  feature_category :incident_management
  urgency :high
  idempotent!

  def perform(project_id)
    project = Project.find_by_id(project_id)

    result = Prometheus::CreateDefaultAlertsService.new(project: project).execute

    log_info(result.message) if result.error?
  end

  private

  def log_info(message)
    logger.info(structured_payload(message: message))
  end
end
