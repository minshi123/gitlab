# frozen_string_literal: true

class ElasticClusterReindexingCronWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :global_search
  urgency :throttled
  idempotent!

  def perform
    task = service.current_task
    return false unless service.current_task

    service.execute(stage: task.stage)
  end

  private

  def service
    Elastic::ClusterReindexingService.new
  end
end
