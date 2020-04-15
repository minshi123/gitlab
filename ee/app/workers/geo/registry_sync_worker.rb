# frozen_string_literal: true

module Geo
  class RegistrySyncWorker < Geo::Scheduler::Secondary::SchedulerWorker
    # This worker does not perform work scoped to a context
    include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

    idempotent!

    private

    # We use inexpensive queries now so we don't need a backoff time
    #
    # Overrides Geo::Scheduler::SchedulerWorker#should_apply_backoff?
    def should_apply_backoff?
      false
    end

    def max_capacity
      # Transition-period-solution.
      # Explained in https://gitlab.com/gitlab-org/gitlab/-/issues/213872#note_336828581
      max(current_node.files_max_capacity / 4, 1)
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
      jobs = replicators.reduce([]) do |jobs, replicator|
        except_ids = scheduled_replicable_ids(replicator.replicable_name)

        jobs << replicator
                  .registry_class
                  .find_unsynced_jobs(batch_size: batch_size, except_ids: except_ids)
                  .map { |job| [replicator.replicable_name, job[replicator.model_foreign_key]] }
      end

      take_batch(*jobs, batch_size: batch_size)
    end

    # Get a batch of failed and synced-but-missing-on-primary resources, taking
    # equal parts from each resource.
    #
    # @return [Array] job arguments of low priority resources
    def find_low_priority_jobs(batch_size:)
      jobs = replicators.reduce([]) do |jobs, replicator|
        except_ids = scheduled_replicable_ids(replicator.replicable_name)

        jobs << replicator
                  .registry_class
                  .find_failed_jobs(batch_size: batch_size, except_ids: except_ids)
                  .map { |job| [replicator.replicable_name, job[replicator.model_foreign_key]] }
      end

      take_batch(*jobs, batch_size: batch_size)
    end

    def scheduled_replicable_ids(replicable_name)
      scheduled_jobs.select { |data| data[:type] == replicable_name }.map { |data| data[:id] }
    end

    def replicators
      Gitlab::Geo::ReplicableModel.replicators.map { |replicator_name| replicator_name.constantize }
    end
  end
end
