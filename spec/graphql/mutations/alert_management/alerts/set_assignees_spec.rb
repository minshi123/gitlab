# frozen_string_literal: true

require 'spec_helper'

describe Mutations::AlertManagement::Alerts::SetAssignees do
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:alert) { create(:alert_management_alert, project: project) }

  let(:current_user) { user_with_permissions }
  let(:assignee_usernames) { [user_with_permissions.username] }
  let(:operation_mode) { Types::MutationOperationModeEnum.enum[:append] }
  let(:args) do
    {
      project_path: project.full_path,
      iid: alert.iid,
      assignee_usernames: assignee_usernames,
      operation_mode: operation_mode
    }
  end

  before_all do
    project.add_developer(user_with_permissions)
  end

  specify { expect(described_class).to require_graphql_authorizations(:update_alert_management_alert) }

  describe '#resolve' do
    subject(:resolve) { mutation_for(project, current_user).resolve(args) }

    shared_examples 'successful resolution' do |operation|
      it 'successfully resolves' do
        expect(::AlertManagement::SetAlertAssigneesService).to receive(:new)
          .with(alert, current_user, assignee_usernames: assignee_usernames, operation_mode: operation)
          .and_call_original

        expect(resolve).to eq(alert: alert.reload, errors: [])
      end
    end

    it_behaves_like 'successful resolution', Types::MutationOperationModeEnum.enum[:append]

    context 'when operation_mode is not specified' do
      let(:operation_mode) { nil }

      it_behaves_like 'successful resolution', Types::MutationOperationModeEnum.enum[:replace]
    end

    context 'when user does not have permissions' do
      let(:current_user) { create(:user) }

      it 'raises an error if the resource is not accessible to the user' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when an error occurs while assigning users' do
      let(:assignee_usernames) { [user_with_permissions.username, 'second_username'] }

      it 'returns errors' do
        expect(resolve).to eq(
          alert: alert,
          errors: [_('Only one assignee is currently supported')]
        )
      end
    end
  end

  def mutation_for(project, user)
    described_class.new(object: project, context: { current_user: user }, field: nil)
  end
end
