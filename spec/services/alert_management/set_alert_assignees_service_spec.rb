# frozen_string_literal: true

require 'spec_helper'

describe AlertManagement::SetAlertAssigneesService do
  let_it_be(:starting_assignee) { create(:user) }
  let_it_be(:unassigned_user) { create(:user) }
  let_it_be(:alert, reload: true) { create(:alert_management_alert) }
  let_it_be(:project) { alert.project }

  let(:current_user) { starting_assignee }
  let(:operation_mode) { nil }
  let(:assignee_usernames) { [] }

  let(:service) { described_class.new(alert, current_user, assignee_usernames: assignee_usernames, operation_mode: operation_mode) }

  before_all do
    project.add_developer(starting_assignee)
    alert.assignees = [starting_assignee]
  end

  describe '#execute' do
    subject(:response) { service.execute }

    shared_examples_for 'an assignment failure' do |error_message|
      it 'which returns an error response' do
        expect(response).to be_error
        expect(response.message).to eq(error_message)
        expect(response.payload[:alert]).to eq(alert)
      end

      it 'which does not change the assignees' do
        original_assignees = alert.assignees.sort

        subject

        expect(alert.reload.assignees).to match_array(original_assignees)
      end
    end

    shared_examples_for 'a successful assignment' do
      after do
        alert.assignees = [starting_assignee]
      end

      it 'which returns a success response' do
        expect(response.payload[:alert]).to eq(alert)
        expect(alert.reload.assignees).to eq(expected_assignees)
      end
    end

    context 'when user does not have permissions' do
      let(:current_user) { unassigned_user }

      it_behaves_like 'an assignment failure', _('You have no permissions')
    end

    context 'when operation is not supported' do
      it_behaves_like 'an assignment failure', _('Unsupported operation mode')
    end

    context 'when operation is expected to be supported' do
      Types::MutationOperationModeEnum.enum.each_value do |operation|
        let(:operation_mode) { operation }

        after do
          alert.assignees = [starting_assignee]
        end

        it "supports the #{operation} operation mode" do
          expect(response).to be_success
        end
      end
    end

    context 'for APPEND operation' do
      let(:operation_mode) { Types::MutationOperationModeEnum.enum[:append] }

      context 'when no users are specified' do
        let(:expected_assignees) { [starting_assignee] }

        it_behaves_like 'a successful assignment'
      end

      context 'when users are specified' do
        let(:assignee_usernames) { [unassigned_user.username] }

        context 'when a different user is already assigned' do
          it_behaves_like 'an assignment failure', _('Only one assignee is currently supported')
        end

        context 'when users are specified and no user is assigned' do
          let(:assignee_usernames) { [unassigned_user.username] }
          let(:expected_assignees) { [unassigned_user] }

          before do
            alert.assignees = []
          end

          it_behaves_like 'a successful assignment'
        end

        context 'when a user is already assigned to the alert' do
          let(:assignee_usernames) { [starting_assignee.username] }
          let(:expected_assignees) { [starting_assignee] }

          it_behaves_like 'a successful assignment'
        end
      end
    end

    context 'for REPLACE operation' do
      let(:operation_mode) { Types::MutationOperationModeEnum.enum[:replace] }

      context 'when no users are specified' do
        let(:expected_assignees) { [] }

        it_behaves_like 'a successful assignment'
      end

      context 'when users are specified' do
        let(:expected_assignees) { [unassigned_user] }
        let(:assignee_usernames) { [unassigned_user.username] }

        it_behaves_like 'a successful assignment'
      end

      context 'when multiple assignees are included' do
        let(:assignee_usernames) { [starting_assignee.username, unassigned_user.username] }

        it_behaves_like 'an assignment failure', _('Only one assignee is currently supported')
      end

      context 'with identical assignees' do
        let(:assignee_usernames) { [starting_assignee.username] }
        let(:expected_assignees) { [starting_assignee] }

        it_behaves_like 'a successful assignment'
      end
    end

    context 'for REMOVE operation' do
      let(:operation_mode) { Types::MutationOperationModeEnum.enum[:remove] }

      context 'when no users are specified' do
        let(:expected_assignees) { [starting_assignee] }

        it_behaves_like 'a successful assignment'
      end

      context 'when users are specified' do
        let(:assignee_usernames) { [starting_assignee.username] }
        let(:expected_assignees) { [] }

        it_behaves_like 'a successful assignment'
      end

      context 'when the user was not already assigned' do
        let(:assignee_usernames) { [unassigned_user.username] }
        let(:expected_assignees) { [starting_assignee] }

        it_behaves_like 'a successful assignment'
      end
    end
  end
end
