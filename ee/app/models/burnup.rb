# frozen_string_literal: true

class Burnup
  include Gitlab::Utils::StrongMemoize

  attr_reader :milestone, :start_date, :due_date, :end_date, :user

  def initialize(milestone:, user:)
    @user = user
    @milestone = milestone

    assign_dates_by_milestone
  end

  def burnup_events
    events = []
    assigned_milestones = {}

    resource_milestone_events.each do |event|
      if event.add_milestone?
        assigned_milestones[event.issue_id] = event.milestone_id
      end

      events << create_burnup_graph_event_by(event, assigned_milestones)

      if event.remove_milestone?
        assigned_milestones[event.issue_id] = nil
      end
    end

    events
  end

  private

  def create_burnup_graph_event_by(event, assigned_milestones)
    {
        created_at: event.created_at,
        action: event.action,
        milestone_id: milestone_id_of(event, assigned_milestones),
        issue_id: event.issue_id
    }
  end

  def assign_dates_by_milestone
    @start_date = milestone.start_date
    @due_date = milestone.due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end
  end

  def milestone_id_of(event, assigned_milestones)
    if event.remove_milestone? && event.milestone_id.nil?
      return assigned_milestones[event.issue_id]
    end

    event.milestone_id
  end

  def resource_milestone_events
    # Here we use the relevant issues to get *all* milestone events for
    # them.

    strong_memoize(:resource_milestone_events) do
      ResourceMilestoneEvent
          .where(issue_id: relevant_issue_ids)
          .where('created_at <= ?', end_time)
          .order(:created_at)
    end
  end

  def relevant_issue_ids
    # We are using all resource milestone events where the
    # milestone in question was added to identify the relevant
    # issues.

    strong_memoize(:relevant_issue_ids) do
      ids = ResourceMilestoneEvent
          .select(:issue_id)
          .where(milestone_id: milestone.id)
          .where(action: :add)
          .distinct

      # We need to perform an additional check whether all these issues are visible to the given user
      IssuesFinder.new(user)
          .execute.preload(:assignees).select(:id).where(id: ids)
    end
  end

  def start_time
    @start_time ||= @start_date.beginning_of_day.to_time
  end

  def end_time
    @end_time ||= @end_date.end_of_day.to_time
  end
end
