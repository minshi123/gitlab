# frozen_string_literal: true

require 'spec_helper'

describe 'User sees user popover', :js do
  set(:project) { create(:project, :repository) }

  let(:user) { project.creator }
  let(:merge_request) do
    create(:merge_request, source_project: project, target_project: project)
  end


  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  subject { page }

  describe 'hovering a over user link in a merge request' do
    before do
      visit project_merge_request_path(project, merge_request)
    end

    it 'displays user popover' do
      find('.js-user-link').hover

      page.within('.user-popover') do
        expect(page).not_to have_button(user.name)
      end
    end
  end
end
