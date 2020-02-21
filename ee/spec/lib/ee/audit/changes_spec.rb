# frozen_string_literal: true

require 'spec_helper'

describe EE::Audit::Changes do
  describe '.audit_changes' do
    let(:current_user) { create(:user, name: 'Mickey Mouse') }
    let(:user) { create(:user, name: 'Donald Duck') }

    subject(:foo_instance) { Class.new { include EE::Audit::Changes }.new }

    before do
      stub_licensed_features(extended_audit_events: true)

      foo_instance.instance_variable_set(:@current_user, user)
      foo_instance.instance_variable_set(:@user, user)

      allow(foo_instance).to receive(:model).and_return(user)
    end

    describe 'non audit changes' do
      context 'when audited column is not changed' do
        it 'does not call the audit event service' do
          user.update!(name: 'Scrooge McDuck')

          expect { foo_instance.audit_changes(:email) }.not_to change { SecurityEvent.count }
        end
      end

      context 'when model is newly created' do
        let(:user) { build(:user) }

        it 'does not call the audit event service' do
          user.update!(name: 'Scrooge McDuck')

          expect { foo_instance.audit_changes(:name) }.not_to change { SecurityEvent.count }
        end
      end
    end

    describe 'audit changes' do
      it 'calls the audit event service' do
        user.update!(name: 'Scrooge McDuck')

        foo_instance.audit_changes(:name)

        aggregate_failures 'audit event service interactions' do
          expect(AuditEventService).to have_received(:new)
            .with(
              current_user, user,
              action: :update, column: :name,
              from: 'Donald Duck', to: 'Scrooge McDuck'
            )
          expect(audit_event_service).to have_received(:for_changes).with(user)
          expect(audit_event_service).to have_received(:security_event)
        end
      end
    end
  end
end
