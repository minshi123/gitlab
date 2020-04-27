# frozen_string_literal: true

module Geo
  class RegistrySyncWorker < Geo::Scheduler::Secondary::SchedulerWorker
    # rubocop:disable Scalability/CronWorkerContext
    # This worker does not perform work scoped to a context
    include CronjobQueue
    # rubocop:enable Scalability/CronWorkerContext

    idempotent!

    LEASE_TIMEOUT = 10.minute

    private

    def perform
      return unless Feature.enabled?(:geo_self_service_framework)

      super
    end

    def max_capacity
      current_node.files_max_capacity
    end

    def schedule_job(replicable_name, record_id)
      job_id = ::Geo::EventWorker.perform_async(replicable_name, :created, model_record_id: record_id)

      { id: record_id, type: replicable_name, job_id: job_id } if job_id
    end

    # Pools for new resources to be transferred
    #
    # @return [Array] resources to be transferred
    def load_pending_resources
      resources = find_unsynced_jobs(batch_size: db_retrieve_batch_size)
      remaining_capacity = db_retrieve_batch_size - resources.count

      if remaining_capacity.zero?
        resources
      else
        resources + find_low_priority_jobs(batch_size: remaining_capacity)
      end
    end

    # Get a batch of unsynced resources, taking equal parts from each resource.
    #
    # @return [Array] job arguments of unsynced resources
    def find_unsynced_jobs(batch_size:)
      jobs = job_finders.reduce([]) do |jobs, job_finder|
        jobs << job_finder.find_unsynced_jobs(batch_size: batch_size)
      end

      take_batch(*jobs, batch_size: batch_size)
    end

    # Get a batch of failed and synced-but-missing-on-primary resources, taking
    # equal parts from each resource.
    #
    # @return [Array] job arguments of low priority resources
    def find_low_priority_jobs(batch_size:)
      jobs = job_finders.reduce([]) do |jobs, job_finder|
        jobs << job_finder.find_failed_jobs(batch_size: batch_size)
        jobs << job_finder.find_synced_missing_on_primary_jobs(batch_size: batch_size)
      end

      take_batch(*jobs, batch_size: batch_size)
    end

    def job_finders
      [
        Geo::RegistrySyncWorker::PackageFileJobFinder.new(scheduled_ids(:package_file))
      ]
    end

    def scheduled_ids(replicable_name)
      scheduled_jobs.select { |data| replicable_name == data[:type] }.map { |data| data[:id] }
    end

    def lease_timeout
      LEASE_TIMEOUT
    end

    def job_finder_classes
      Gitlab::Geo::ReplicableModel.replicators.map { |replicator_name| replicator_name.constantize.finder_class }
    end
  end
end
