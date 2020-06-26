# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User edits a merge request', :js do
  include Select2Helper

  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)

    visit(edit_project_merge_request_path(project, merge_request))
  end

  context "Squash commits"  do
    # If the MR selection is checked to begin with
    # User change settings to "Do not allow" (unchecked)
    # Go to edit MR and save it
    # Change project settings to be "Allow" (uncheck)
    # Go to edit page, squash commit should be checked
    it 'recovers MR setting of squash true after "Do not allow" is saved' do
      merge_request.update!(squash: true)
      project.project_setting.update!(squash_option: 'never')
      visit(edit_project_merge_request_path(project, merge_request))
      click_button('Save changes')

      project.project_setting.update!(squash_option: 'default_off')
      visit(edit_project_merge_request_path(project, merge_request))

      checkbox = find("#merge_request_squash")
      expect(checkbox.selected?).to be(true)
    end

    # If the MR selection is unchecked to begin with
    # User change settings to "Required" (checked)
    # Go to edit MR and save it
    # Change project settings to be "Encourage" (check)
    # Go to edit page, squash commit will recover its original MR select and will be unchecked

    # it 'recovers MR setting of squash false after "Required" is saved' do

    # end
  end

  it 'changes the target branch' do
    expect(page).to have_content('From master into feature')

    select2('merge-test', from: '#merge_request_target_branch')
    click_button('Save changes')

    expect(page).to have_content("Request to merge #{merge_request.source_branch} into merge-test")
    expect(page).to have_content("changed target branch from #{merge_request.target_branch} to merge-test")
  end
end
