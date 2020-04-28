# frozen_string_literal: true

require 'spec_helper'

describe 'Commit > User view commits', :js do
  include RepoHelpers

  let(:project) { create(:project, :public, :repository) }
  let(:user) { project.creator }
  let(:commit) { project.commit }

  before do
    visit project_commits_path(project)
  end

  describe 'Commits List' do
    it 'displays the correct number of commits per day in the header' do
      expect(first('.js-commit-header').find('.commits-count').text).to include('1')
    end

    it 'lists the correct number of commits' do
      expect(page).to have_selector('#commits-list > li:nth-child(2) > ul', count: 1)
    end
  end
end
