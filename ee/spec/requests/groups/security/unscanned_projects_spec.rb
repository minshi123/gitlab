# frozen_string_literal: true

require 'spec_helper'

describe 'GET /groups/*group_id/-/security/unscanned_projects' do
  let(:group) { create(:group) }

  it_behaves_like 'security dashboard JSON endpoint' do
    let(:vulnerable) { group }
    let(:security_dashboard_request) do
      get group_security_unscanned_projects_path(group, format: :json)
    end
  end

  context 'when the current user is authenticated' do
    let(:user) { create(:user) }

    before do
      stub_licensed_features(security_dashboard: true)
      login_as(user)

      group.add_developer(user)
    end

    it 'returns a list of projects in the group that have no configured security scans' do
      get group_security_unscanned_projects_path(group, format: :json)

      expect(response).to have_gitlab_http_status(200)
      p json_response
    end

    it 'includes projects in subgroups'
    it 'does not use N+1 queries'
  end
end
