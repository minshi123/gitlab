# frozen_string_literal: true

require 'spec_helper'

describe 'EE > Projects > Licenses > Mainter views policies' do
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
  end

  context 'when policies are not configured' do
    let(:help_path) { help_page_path('user/application_security/license_compliance/index') }

    it 'displays a link to the documentation to configure license compliance' do
      expect(page).to have_content('License Compliance')
      expect(page).to have_selector("div[data-documentation-path='#{help_path}']")
    end
  end
end
