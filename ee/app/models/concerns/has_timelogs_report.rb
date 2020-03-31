# frozen_string_literal: true

module HasTimelogsReport
  extend ActiveSupport::Concern

  def timelogs(start_date, end_date)
    @timelogs ||= timelogs_for(start_date, end_date)
  end

  def user_can_access_group_timelogs?(current_user)
    return unless feature_available?(:group_timelogs)

    Ability.allowed?(current_user, :read_group_timelogs, self)
  end

  private

  def timelogs_for(start_date, end_date)
    start_date = start_date&.to_time&.beginning_of_day
    end_date = end_date&.to_time&.end_of_day

    Timelog.between_dates(start_date, end_date).for_issues_in_group(self)
  end
end
