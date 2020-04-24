# frozen_string_literal: true

require 'spec_helper'

describe GitlabSchema.types['SecurityDashboard'] do
  let_it_be(:project) { create(:project) }
  let_it_be(:other_project) { create(:project) }
  let_it_be(:user) { create(:user, security_dashboard_projects: [project]) }

  let(:fields) do
    %i[projects]
  end

  before do
    project.add_developer(user)
    other_project.add_developer(user)
  end

  subject { GitlabSchema.execute(query, context: { current_user: current_user }).as_json }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'projects' do
    let(:query) do
      %(
        query {
          securityDashboard {
            projects {
              nodes {
                id
              }
            }
          }
        }
      )
    end

    let(:projects) { subject.dig('data', 'securityDashboard', 'projects') }

    context 'when user is not logged in' do
      let(:current_user) { nil }

      it 'is a nil' do
        expect(projects).to be_nil
      end
    end

    context 'when user is logged in' do
      let(:current_user) { user }

      it 'is a list of projects configured for instance security dashboard' do
        project_ids = projects['nodes'].pluck('id')

        expect(project_ids).to eq [GitlabSchema.id_from_object(project).to_s]
      end
    end
  end
end
