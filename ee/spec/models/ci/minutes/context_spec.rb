# frozen_string_literal: true

require 'spec_helper'

describe Ci::Minutes::Context do
  let_it_be(:group) { create(:group) }
  let(:project) { build(:project, namespace: group) }

  describe 'delegation' do
    subject { described_class.new(project, group) }

    it { is_expected.to delegate_method(:shared_runners_remaining_minutes_below_threshold?).to(:level) }
    it { is_expected.to delegate_method(:shared_runners_minutes_used?).to(:level) }
    it { is_expected.to delegate_method(:shared_runners_minutes_limit_enabled?).to(:level) }
    it { is_expected.to delegate_method(:name).to(:namespace).with_prefix }
    it { is_expected.to delegate_method(:last_ci_minutes_usage_notification_level).to(:namespace) }
  end
end
