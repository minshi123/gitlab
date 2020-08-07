# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GroupDeployKey do
  it { is_expected.to validate_presence_of(:user) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:groups) }

  it 'is of type DeployKey' do
    expect(build(:group_deploy_key).type).to eq('DeployKey')
  end
end
