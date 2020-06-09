# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User edits a merge request', :js do
  include Select2Helper
  using RSpec::Parameterized::TableSyntax

  let(:project) { create(:project, :repository) }
  let(:merge_request) { create(:merge_request, source_project: project, target_project: project) }
  let(:user) { create(:user) }

  before do
    project.add_maintainer(user)
    sign_in(user)

    visit(edit_project_merge_request_path(project, merge_request))
  end

  context "when the Squash-and-Merge feature is enabled" do
    where(:squash_option, :checkbox_selected, :checkbox_disabled) do
      "always_squash"            | true  | true
      "never_squash"             | false | true
      "enabled_with_default_on"  | true  | false
      "enabled_with_default_off" | false | false
    end

    with_them do
      let(:project) { create(:project, :repository, squash_option: squash_option) }

      it 'the checkbox reflects the correct option' do
        visit(edit_project_merge_request_path(project, merge_request))

        checkbox = find("#merge_request_squash")
        expect(checkbox.disabled?).to eql(checkbox_disabled)
        expect(checkbox.selected?).to eql(checkbox_selected)
      end
    end
  end

  it 'changes the target branch' do
    expect(page).to have_content('From master into feature')

    select2('merge-test', from: '#merge_request_target_branch')
    click_button('Save changes')

    expect(page).to have_content("Request to merge #{merge_request.source_branch} into merge-test")
    expect(page).to have_content("changed target branch from #{merge_request.target_branch} to merge-test")
  end
end
