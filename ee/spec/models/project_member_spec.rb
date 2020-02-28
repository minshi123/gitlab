# frozen_string_literal: true
require 'spec_helper'

describe ProjectMember do
  it { is_expected.to include_module(EE::ProjectMember) }

  it_behaves_like 'member validations' do
    let(:entity) { create(:project, group: group)}
  end

  context 'validates GMA enforcement' do
    let(:group) { create(:group_with_managed_accounts, :private) }
    let(:user) { create(:user, :group_managed, managing_group: group) }
    let(:entity) { create(:project, namespace: group)}

    before do
      stub_feature_flags(group_managed_accounts: true)
    end

    context 'enforced group managed account enabled' do
      before do
        allow_any_instance_of(SamlProvider).to receive(:enforced_group_managed_accounts?).and_return(true)
      end

      it 'allows adding the project member' do
        member = described_class.add_user(entity, user, Member::DEVELOPER)

        expect(member).to be_valid
      end

      it 'does not add the the project member' do
        member = described_class.add_user(entity, create(:user), Member::DEVELOPER)

        expect(member).not_to be_valid
        expect(member.errors.messages[:user]).to eq(['is not in the group enforcing Group Managed Account'])
      end
    end

    context 'enforced group managed account disabled' do
      it 'allows adding the group member' do
        member = described_class.add_user(entity, create(:user), Member::DEVELOPER)

        expect(member).to be_valid
      end
    end
  end
end
