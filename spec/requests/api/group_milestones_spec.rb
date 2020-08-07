# frozen_string_literal: true

require 'spec_helper'

RSpec.describe API::GroupMilestones do
  let(:user) { create(:user) }
  let(:group) { create(:group, :private) }
  let(:project) { create(:project, namespace: group) }
  let!(:group_member) { create(:group_member, group: group, user: user) }
  let!(:closed_milestone) { create(:closed_milestone, group: group, title: 'version1', description: 'closed milestone') }
  let!(:milestone) { create(:milestone, group: group, title: 'version2', description: 'open milestone') }

  it_behaves_like 'group and project milestones', "/groups/:id/milestones" do
    let(:route) { "/groups/#{group.id}/milestones" }
  end

  describe 'GET /groups/:id/milestones' do
    context 'when include_parent_milestones is true' do
      let_it_be(:parent_group) { create(:group, :public) }
      let_it_be(:child_group) { create(:group, :public, parent: parent_group) }
      let_it_be(:group_milestone) { create(:milestone, group: parent_group) }
      let_it_be(:child_group_milestone) { create(:milestone, group: child_group) }

      before do
        child_group.add_developer(user)
      end

      it 'includes parent groups milestones' do
        milestones = [child_group_milestone, group_milestone]

        get api("/groups/#{child_group.id}/milestones", user),
            params: { include_parent_milestones: true }

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response.size).to eq(2)
        expect(json_response.map { |entry| entry["id"] }).to eq(milestones.map(&:id))
      end

      context 'when user has no access to an ancestor group' do
        before do
          [child_group, parent_group].each do |group|
            group.update!(visibility_level: Gitlab::VisibilityLevel::PRIVATE)
          end
        end

        it 'does not show ancestor group milestones' do
          milestones = [child_group_milestone]

          get api("/groups/#{child_group.id}/milestones", user),
              params: { include_parent_milestones: true }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(1)
          expect(json_response.map { |entry| entry["id"] }).to eq(milestones.map(&:id))
        end
      end

      context 'when filtering by iids' do
        it 'does not filter by iids' do
          milestones = [child_group_milestone, group_milestone]

          get api("/groups/#{child_group.id}/milestones", user),
              params: { include_parent_milestones: true, iids: [group_milestone.iid] }

          expect(response).to have_gitlab_http_status(:ok)
          expect(json_response.size).to eq(2)
          expect(json_response.map { |entry| entry["id"] }).to eq(milestones.map(&:id))
        end
      end
    end
  end

  def setup_for_group
    context_group.update(visibility_level: Gitlab::VisibilityLevel::PUBLIC)
    context_group.add_developer(user)
    public_project.update(namespace: context_group)
    context_group.reload
  end
end
