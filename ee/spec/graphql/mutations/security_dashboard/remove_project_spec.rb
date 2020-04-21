require 'spec_helper'

describe Mutations::SecurityDashboard::RemoveProject do
  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }

  describe '#resolve' do
    let_it_be(:project) { create(:project) }
    let_it_be(:already_added_project) { create(:project) }

    let_it_be(:user) { create(:user, security_dashboard_projects: [already_added_project]) }

    let(:project_id) { GitlabSchema.id_from_object(project) }

    before do
      already_added_project.add_developer(user)
    end

    subject { mutation.resolve(project_id: project_id) }

    context 'when user is not logged_in' do
      let(:current_user) { nil }

      it { is_expected.to be_nil }
    end

    context 'when user is logged_in' do
      let(:current_user) { user }

      context 'when project is not configured in security dashboard' do
        it { is_expected.to eq(project_id: nil) }
      end

      context 'when project is configured in security dashboard' do
        let(:project_id) { GitlabSchema.id_from_object(already_added_project) }

        it { is_expected.to eq(project_id: project_id) }
      end
    end
  end
end
