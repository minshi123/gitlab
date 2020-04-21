# frozen_string_literal: true
require 'spec_helper'

describe Mutations::SecurityDashboard::AddProjects do
  let(:mutation) { described_class.new(object: nil, context: { current_user: current_user }, field: nil) }

  describe '#resolve' do
    let_it_be(:project) { create(:project) }
    let_it_be(:my_project) { create(:project) }
    let_it_be(:already_added_project) { create(:project) }

    let_it_be(:user) { create(:user, security_dashboard_projects: [already_added_project]) }

    let(:project_ids) { [project, my_project, already_added_project].map(&GitlabSchema.method(:id_from_object)).map(&:to_s) }

    before do
      my_project.add_developer(user)
      already_added_project.add_developer(user)
    end

    subject { mutation.resolve(project_ids: project_ids) }

    context 'when user is not logged_in' do
      let(:current_user) { nil }

      it { is_expected.to be_nil }
    end

    context 'when user is logged_in' do
      let(:current_user) { user }

      context 'when security_dashboard is not enabled' do
        it 'does not add any project to the security dashboard' do
          expect(subject[:added_project_ids]).to be_empty
        end
      end

      context 'when security_dashboard is enabled' do
        before do
          stub_licensed_features(security_dashboard: true)
        end

        it 'adds project that is available to the user to the security dashboard', :aggregate_failures do
          expect(subject[:added_project_ids]).to eq([GitlabSchema.id_from_object(my_project)])
          expect(user.security_dashboard_projects).to include(my_project)
        end

        it 'does not add project that already exist in the security dashboard', :aggregate_failures do
          expect(subject[:duplicated_project_ids]).to eq([GitlabSchema.id_from_object(already_added_project)])
          expect(user.security_dashboard_projects).to include(already_added_project)
        end

        it 'does not add project that is not available for the user' do
          expect(subject[:invalid_project_ids]).to eq([GitlabSchema.id_from_object(project)])
        end
      end
    end
  end
end
