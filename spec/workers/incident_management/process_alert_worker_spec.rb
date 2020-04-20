# frozen_string_literal: true

require 'spec_helper'

describe IncidentManagement::ProcessAlertWorker do
  let_it_be(:project) { create(:project) }

  describe '#perform' do
    let(:alert_management_alert_id) { nil }
    let(:alert_payload) { { alert: 'payload' } }
    let(:new_issue) { instance_double(Issue, id: 42, persisted?: true) }
    let(:create_issue_service) { instance_double(IncidentManagement::CreateIssueService, execute: new_issue) }

    subject { described_class.new.perform(project.id, alert_payload, alert_management_alert_id) }

    before do
      allow(IncidentManagement::CreateIssueService)
        .to receive(:new).with(project, alert_payload)
        .and_return(create_issue_service)
    end

    it 'calls create issue service' do
      expect(Project).to receive(:find_by_id).and_call_original

      expect(IncidentManagement::CreateIssueService)
        .to receive(:new).with(project, alert_payload)
        .and_return(create_issue_service)

      expect(create_issue_service).to receive(:execute)

      subject
    end

    context 'with invalid project' do
      let(:invalid_project_id) { 0 }

      subject { described_class.new.perform(invalid_project_id, alert_payload) }

      it 'does not create issues' do
        expect(Project).to receive(:find_by_id).and_call_original
        expect(IncidentManagement::CreateIssueService).not_to receive(:new)

        subject
      end
    end

    context 'when alert_management_alert_id is present' do
      let(:alert_management_alert_id) { 503 }
      let(:alert) { instance_double(AlertManagement::Alert, update!: true) }

      it 'updates AlertManagement::Alert#issue_id' do
        expect(AlertManagement::Alert)
          .to receive(:find_by_id)
          .with(alert_management_alert_id)
          .and_return(alert)

        expect(alert).to receive(:update!).with(issue_id: new_issue.id)

        subject
      end
    end
  end
end
