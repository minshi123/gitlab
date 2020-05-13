# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::CreateAlertIssueService do
  let!(:user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let(:payload) do
    {
      'annotations' => {
        'title' => 'Alert title'
      },
      'startsAt' => '2020-04-27T10:10:22.265949279Z',
      'generatorURL' => 'http://8d467bd4607a:9090/graph?g0.expr=vector%281%29&g0.tab=1'
    }
  end
  let!(:generic_alert) { create(:alert_management_alert, project: project, status: 'triggered', payload: payload) }
  let!(:prometheus_alert) { create(:alert_management_alert, :prometheus, project: project, status: 'triggered', payload: payload) }
  let!(:alert) { generic_alert }

  describe '#execute' do
    subject(:execute) { described_class.new(alert, user).execute }

    before do
      allow(user).to receive(:can?).and_call_original
      allow(user).to receive(:can?)
        .with(:update_alert_management_alert, project)
        .and_return(can_create)
    end

    shared_examples 'creating an alert' do
      it 'creates an issue' do
        expect { execute }.to change { project.issues.count }.by(1)
      end

      it 'returns a created issue' do
        expect(execute.payload).to eq(issue: Issue.last)
      end

      it 'has a successful status' do
        expect(execute).to be_success
      end

      it 'updates alert.issue_id' do
        execute

        expect(alert.reload.issue_id).to eq(Issue.last.try(:id))
      end

      it 'sets issue author to the current user' do
        execute

        expect(Issue.last.author).to eq(user)
      end
    end

    context 'when a user is allowed to create an issue' do
      let(:can_create) { true }

      before do
        project.add_developer(user)
      end

      context 'when the alert is prometheus alert' do
        let(:alert) { prometheus_alert }

        it_behaves_like 'creating an alert'
      end

      context 'when the alert is generic' do
        let(:alert) { generic_alert }

        it_behaves_like 'creating an alert'
      end

      context 'when alert cannot be updated' do
        before do
          # invalidate alert
          too_many_hosts = Array.new(AlertManagement::Alert::HOSTS_MAX_LENGTH + 1) { |_| 'host' }
          alert.update_columns(hosts: too_many_hosts)
        end

        it 'responds with error' do
          expect(execute).to be_error
          expect(execute.message).to eq('Hosts hosts array is over 255 chars')
        end
      end

      context 'when alert already has an attached issue' do
        let!(:issue) { create(:issue, project: project) }

        before do
          alert.update_columns(issue_id: issue.id)
        end

        it 'does not create yet another issue' do
          expect { execute }.not_to change(Issue, :count)
        end

        it 'responds with error' do
          expect(execute).to be_error
          expect(execute.message).to eq('An issue already exists')
        end
      end

      context 'when alert_management_create_alert_issue feature flag is disabled' do
        before do
          stub_feature_flags(alert_management_create_alert_issue: false)
        end

        it 'responds with error' do
          expect(execute).to be_error
          expect(execute.message).to eq('You have no permissions')
        end
      end
    end

    context 'when a user is not allowed to create an issue' do
      let(:can_create) { false }

      it 'responds with error' do
        expect(execute).to be_error
        expect(execute.message).to eq('You have no permissions')
      end
    end
  end
end
