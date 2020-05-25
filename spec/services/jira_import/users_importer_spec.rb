# frozen_string_literal: true

require 'spec_helper'

describe JiraImport::UsersImporter do
  include JiraServiceHelper

  let(:project)  { create(:project) }
  let(:start_at) { 7 }

  let(:importer) { described_class.new(project, start_at) }

  subject { importer.execute }

  describe '#execute' do
    before  do
      stub_jira_service_test
    end

    context 'when jira import is not configured propeerly' do
      it 'raises an error' do
        expect { subject }.to raise_error(Projects::ImportService::Error)
      end
    end

    context 'when Jira import is configured correctly' do
      let!(:jira_service) { create(:jira_service, project: project, active: true) }

      before do
        client = double
        expect(importer).to receive(:client).and_return(client)
        allow(client).to receive(:get).with('/rest/api/2/users?maxResults=50&startAt=7')
          .and_return(jira_users)
      end

      context 'when jira clients returns an empty array' do
        let(:jira_users) { [] }

        it 'returns nil' do
          expect(subject).to be_nil
        end
      end

      context 'when jira clients returns an results' do
        let(:jira_users)   { [{ 'name'  => 'user1' }, { 'name' => 'user2' }] }
        let(:mapped_users) { [{ name: 'user1', gitlab_id: 5 }] }

        before do
          expect(JiraImport::UsersMapper).to receive(:new).with(project, jira_users)
          .and_return(double(execute: mapped_users))
        end

        it 'returns the mapped users' do
          expect(subject).to eq(mapped_users)
        end
      end
    end
  end
end
