# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::JiraImport::IssueSerializer do
  describe '#execute' do
    let_it_be(:project) { create(:project) }

    let(:summary) { 'some title' }
    # let(:description) { 'basic description' }
    let(:description) { "text = 'Color - {color:#97a0af}Light Gray{color}'" }
    let(:jira_issue) do
      double(
        id: '1234',
        key: 'PROJECT-5',
        summary: summary,
        description: description
      )
    end

    subject { described_class.new(project, jira_issue).execute }

    it 'creates a valid Issue instance' do
      issue = subject

      expect(issue).to be_instance_of(Issue)
      expect(issue).to be_valid
    end

    it 'sets title based on jira issue summary' do
      binding.pry
      expect(subject.title).to eq(summary)
    end

    it 'sets description based on jira issue description' do
      expect(subject.title).to eq(summary)
    end

    it 'sets project creator as an author' do
      expect(subject.author).to eq(project.creator)
    end
  end
end