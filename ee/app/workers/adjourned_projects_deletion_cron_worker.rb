# frozen_string_literal: true

class AdjournedProjectsDeletionCronWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue

  feature_category :authentication_and_authorization

  def perform
    deletion_cutoff = Gitlab::CurrentSettings.deletion_adjourned_period.days.ago.to_date

    Project.with_route.with_deleting_user.aimed_for_deletion(deletion_cutoff).find_each(batch_size: 100) do |project| # rubocop: disable CodeReuse/ActiveRecord
      with_context(project: project, user: project.deleting_user) do
        AdjournedProjectDeletionWorker.perform_async(project.id)
      end
    end
  end
end
