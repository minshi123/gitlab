# frozen_string_literal: true

require 'spec_helper'

describe 'EE > Projects > Licenses > Maintainer views policies' do
  let(:project) { create(:project) }
  let(:maintainer) do
    create(:user).tap do |user|
      project.add_maintainer(user)
    end
  end
  let(:path) { project_licenses_path(project) }

  before do
    sign_in(maintainer)
    stub_licensed_features(license_management: true)
    visit path
    wait_for_requests
  end

  context 'when policies are not configured' do
    let(:help_path) { help_page_path('user/application_security/license_compliance/index') }

    it 'displays a link to the documentation to configure license compliance' do
      expect(page).to have_content('License Compliance')
      expect(page).to have_selector("div[data-documentation-path='#{help_path}']")
    end
  end

  context "when a policy is configured", :js do
    let!(:mit) { create(:software_license, :mit) }
    let!(:mit_policy) { create(:software_license_policy, :denied, software_license: mit, project: project) }
    let!(:pipeline) { create(:ee_ci_pipeline, project: project, builds: [create(:ee_ci_build, :license_scan_v2, :success)]) }

    it 'displays licenses detected in the most recent scan report' do
      expect(page).to have_content(mit.name)
    end

    it 'displays the classification for detected licenses' do
      expect(page).to have_content(mit.classification)
    end
  end
end
