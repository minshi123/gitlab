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
  end

  context 'when policies are not configured' do
    let(:help_path) { help_page_path('user/application_security/license_compliance/index') }

    before do
      visit path
    end

    it 'displays a link to the documentation to configure license compliance' do
      expect(page).to have_content('License Compliance')
      expect(page).to have_selector("div[data-documentation-path='#{help_path}']")
    end
  end

  context "when a policy is configured", :js do
    let!(:mit) { create(:software_license, :mit) }
    let!(:mit_policy) { create(:software_license_policy, :denied, software_license: mit, project: project) }
    let!(:pipeline) { create(:ee_ci_pipeline, project: project, builds: [create(:ee_ci_build, :license_scan_v2, :success)]) }
    let(:report) { JSON.parse(fixture_file('security_reports/gl-license-management-report-v2.json', dir: 'ee')) }
    let(:expected_components) do
      report['dependencies']
        .find_all { |dependency| dependency['licenses'].include?(mit.spdx_identifier) }
        .map { |dependency| dependency['name'] }
    end

    before do
      visit path
      wait_for_requests
    end

    it 'displays licenses detected in the most recent scan report' do
      selector = "div[data-spdx-id='#{mit.spdx_identifier}'"
      expect(page).to have_selector(selector)

      row = page.find(selector)
      expect(row).to have_content(mit.name)
      expect(row).to have_content(expected_components.join(' and '))
    end
  end
end
