# frozen_string_literal: true

require 'spec_helper'

describe Burnup do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  let!(:project) { create(:project, :private) }

  let!(:start_date) { Date.parse('2020-01-04') }
  let!(:due_date) { Date.parse('2020-01-26') }

  let!(:milestone1) { create(:milestone, :with_dates, title: 'v1.0', project: project, start_date: start_date, due_date: due_date) }
  let!(:milestone2) { create(:milestone, :with_dates, title: 'v1.1', project: project, start_date: start_date + 1.year, due_date: due_date + 1.year) }

  let!(:issue1) { create(:issue, project: project, milestone: milestone1) }
  let!(:issue2) { create(:issue, project: project, milestone: milestone1) }
  let!(:issue3) { create(:issue, project: project, milestone: milestone1) }
  let!(:other_issue) { create(:issue, project: project) }

  let!(:weight_event1) { create(:resource_weight_event, issue: issue1, weight: 9, created_at: start_date + 1.second) }
  let!(:weight_event2) { create(:resource_weight_event, issue: issue2, weight: 3, created_at: start_date + 1.second) }
  let!(:weight_event3) { create(:resource_weight_event, issue: issue3, weight: 1, created_at: start_date + 2.days) }
  let!(:weight_event4) { create(:resource_weight_event, issue: issue3, weight: 2, created_at: start_date + 2.days + 23.hours + 59.minutes + 59.seconds) }
  let!(:weight_event5) { create(:resource_weight_event, issue: issue3, weight: 7, created_at: start_date + 4.days + 1.second) }

  let!(:event1) { create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone1, created_at: start_date + 1.second) }
  let!(:event2) { create(:resource_milestone_event, issue: issue2, action: :add, milestone: milestone1, created_at: start_date + 2.seconds) }
  let!(:event3) { create(:resource_milestone_event, issue: issue3, action: :add, milestone: milestone1, created_at: start_date + 1.day) }
  let!(:event4) { create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: start_date + 2.days + 1.second) }
  let!(:event5) { create(:resource_milestone_event, issue: issue3, action: :add, milestone: milestone2, created_at: start_date + 3.days) }
  let!(:event6) { create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: start_date + 4.days) }

  before do
    project.add_maintainer(user)
  end

  describe '#burnup_events' do
    it 'returns the expected events' do
      # This event is not within the time frame of the milestone's start and due date
      # but it should nevertheless be part of the result set since the 'add' events
      # are important for the graph.
      create(:resource_milestone_event, issue: issue1, action: :add, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)

      # These events are ignored
      create(:resource_milestone_event, issue: other_issue, action: :remove, milestone: milestone2, created_at: start_date.beginning_of_day - 1.second)
      create(:resource_milestone_event, issue: issue3, action: :remove, milestone: nil, created_at: due_date.end_of_day + 1.second)

      data = described_class.new(milestone: milestone1, user: user).burnup_events

      expect(data.size).to eq(7)

      expect(data[0]).to include(action: 'add', issue_id: issue1.id, milestone_id: milestone2.id, weight: nil, created_at: start_date.beginning_of_day - 1.second)
      expect(data[1]).to include(action: 'add', issue_id: issue1.id, milestone_id: milestone1.id, weight: 9, created_at: start_date + 1.second)
      expect(data[2]).to include(action: 'add', issue_id: issue2.id, milestone_id: milestone1.id, weight: 3, created_at: start_date + 2.seconds)
      expect(data[3]).to include(action: 'add', issue_id: issue3.id, milestone_id: milestone1.id, weight: nil, created_at: start_date + 1.day)
      expect(data[4]).to include(action: 'remove', issue_id: issue3.id, milestone_id: milestone1.id, weight: 1, created_at: start_date + 2.days + 1.second)
      expect(data[5]).to include(action: 'add', issue_id: issue3.id, milestone_id: milestone2.id, weight: 2, created_at: start_date + 3.days)
      expect(data[6]).to include(action: 'remove', issue_id: issue3.id, milestone_id: milestone2.id, weight: 2, created_at: start_date + 4.days)
    end

    it 'excludes issues which should not be visible to the user ' do
      data = described_class.new(milestone: milestone1, user: other_user).burnup_events

      expect(data).to be_empty
    end
  end
end
