# frozen_string_literal: true

# Used by burndown and burnup charts.
class ChartDataBase
  attr_reader :issues, :start_date, :end_date, :due_date

  def initialize(issues, start_date, due_date, params = {})
    @start_date = start_date
    @due_date = due_date
    @end_date = if due_date.blank? || due_date > Date.today
                  Date.today
                else
                  due_date
                end

    @issues = filter_issues_created_before(@end_date, issues)
    @params = params
  end

  def valid?
    start_date && due_date
  end

  private

  def filter_issues_created_before(date, issues)
    return [] unless valid?

    issues.where('issues.created_at <= ?', date.end_of_day).includes(:project)
  end

  def closed_issues
    issues.select(&:closed?)
  end
end
