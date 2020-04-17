# frozen_string_literal: true

require 'spec_helper'

describe SprintsFinder do
  let(:now) { Time.now }
  let(:group) { create(:group) }
  let(:project_1) { create(:project, namespace: group) }
  let(:project_2) { create(:project, namespace: group) }
  let!(:sprint_1) { create(:sprint, group: group, title: 'one test', start_date: now - 1.day, due_date: now) }
  let!(:sprint_2) { create(:sprint, group: group, start_date: now + 1.day, due_date: now + 2.days) }
  let!(:sprint_3) { create(:sprint, project: project_1, state: 'active', start_date: now + 2.days, due_date: now + 3.days) }
  let!(:sprint_4) { create(:sprint, project: project_2, state: 'active', start_date: now + 4.days, due_date: now + 5.days) }

  it 'returns sprints for projects' do
    result = described_class.new(project_ids: [project_1.id, project_2.id], state: 'all').execute

    expect(result).to contain_exactly(sprint_3, sprint_4)
  end

  it 'returns sprints for groups' do
    result = described_class.new(group_ids: group.id,  state: 'all').execute

    expect(result).to contain_exactly(sprint_1, sprint_2)
  end

  context 'sprints for groups and project' do
    let(:result) do
      described_class.new(project_ids: [project_1.id, project_2.id], group_ids: group.id, state: 'all').execute
    end

    it 'returns sprints for groups and projects' do
      expect(result).to contain_exactly(sprint_1, sprint_2, sprint_3, sprint_4)
    end

    it 'orders sprints by due date' do
      sprint = create(:sprint, group: group, due_date: now - 2.days)

      expect(result.first).to eq(sprint)
      expect(result.second).to eq(sprint_1)
      expect(result.third).to eq(sprint_2)
    end
  end

  context 'with filters' do
    let(:params) do
      {
          project_ids: [project_1.id, project_2.id],
          group_ids: group.id,
          state: 'all'
      }
    end

    before do
      sprint_1.close
      sprint_3.close
    end

    it 'filters by active state' do
      params[:state] = 'active'
      result = described_class.new(params).execute

      expect(result).to contain_exactly(sprint_2, sprint_4)
    end

    it 'filters by closed state' do
      params[:state] = 'closed'
      result = described_class.new(params).execute

      expect(result).to contain_exactly(sprint_1, sprint_3)
    end

    it 'filters by title' do
      result = described_class.new(params.merge(title: 'one test')).execute

      expect(result.to_a).to contain_exactly(sprint_1)
    end

    it 'filters by search_title' do
      result = described_class.new(params.merge(search_title: 'one t')).execute

      expect(result.to_a).to contain_exactly(sprint_1)
    end

    context 'by timeframe' do
      it 'returns sprints with start_date and due_date between timeframe' do
        params.merge!(start_date: now - 1.day, end_date: now + 3.days)

        sprints = described_class.new(params).execute

        expect(sprints).to match_array([sprint_1, sprint_2, sprint_3])
      end

      it 'returns sprints which starts before the timeframe' do
        sprint = create(:sprint, project: project_2, start_date: now - 5.days)
        params.merge!(start_date: now - 3.days, end_date: now - 2.days)

        sprints = described_class.new(params).execute

        expect(sprints).to match_array([sprint])
      end

      it 'returns sprints which ends after the timeframe' do
        sprint = create(:sprint, project: project_2, due_date: now + 6.days)
        params.merge!(start_date: now + 6.days, end_date: now + 7.days)

        sprints = described_class.new(params).execute

        expect(sprints).to match_array([sprint])
      end
    end
  end

  describe '#find_by' do
    it 'finds a single sprint' do
      finder = described_class.new(project_ids: [project_1.id], state: 'all')

      expect(finder.find_by(iid: sprint_3.iid)).to eq(sprint_3)
    end
  end
end
