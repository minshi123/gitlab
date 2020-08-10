# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupDeployKey do
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:groups) }

  it 'is of type DeployKey' do
    expect(build(:group_deploy_key).type).to eq('DeployKey')
  end

  describe '#group_deploy_keys_group_for' do
    let_it_be(:group_deploy_key) { create(:group_deploy_key) }
    let_it_be(:group) { create(:group) }

    subject { group_deploy_key.group_deploy_keys_group_for(group) }

    context 'when this group deploy key is linked to a given group' do
      it 'returns the relevant group_deploy_keys_group association' do
        group_deploy_keys_group = create(:group_deploy_keys_group, group: group, group_deploy_key: group_deploy_key)

        expect(subject).to eq(group_deploy_keys_group)
      end
    end

    context 'when this group deploy key is not linked to a given group' do
      it { is_expected.to be_nil }
    end
  end
end
