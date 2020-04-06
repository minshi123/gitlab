# frozen_string_literal: true

class CreateDefaultPrometheusAlertsWorker
  include ApplicationWorker

  feature_category :metrics
  urgency :high
  idempotent!

  def perform(project_id)
    # rubocop: disable CodeReuse/ActiveRecord
    project = Project.find_by(id: project_id)
    # rubocop: enable CodeReuse/ActiveRecord

    Prometheus::CreateDefaultAlertService.new(project: project).execute
  end
end
