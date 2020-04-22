# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Namespace::RootStorageLimitAlert, type: :model do
  let_it_be(:user) { create(:user) }
  let(:namespace) { user.namespace }
  let(:other_namespace) { create(:namespace) }
  let(:model) { described_class.new(namespace, user) }
  let(:create_statistics) { create(:namespace_root_storage_statistics, namespace: namespace, storage_size: current_size)}
  let(:current_size) { 60.megabytes }

  before do
    create_statistics

    stub_application_setting(namespace_storage_size_limit: 100)
  end

  describe '#level' do
    subject { model.level }

    context 'returns nil when below threshold' do
      let(:current_size) { 49.megabytes }

      it { is_expected.to be_nil }
    end

    context 'returns info when above info threshold' do
      let(:current_size) { 50.megabytes }

      it { is_expected.to eq(:info) }
    end

    context 'returns info when above warning threshold' do
      let(:current_size) { 75.megabytes }

      it { is_expected.to eq(:warning) }
    end

    context 'returns danger when above danger threshold' do
      let(:current_size) { 95.megabytes }

      it { is_expected.to eq(:danger) }
    end
  end

  describe '#message' do
    subject { model.message }

    context 'when above limit' do
      let(:current_size) { 110.megabytes }

      it 'returns message with read-only warning' do
        expect(subject).to include("#{namespace.name} is now read-only")
      end
    end

    context 'when not admin of namespace' do
      let(:namespace) { other_namespace }

      it { is_expected.to be_nil }
    end

    context 'when below limit' do
      it { is_expected.to include('If you reach 100% storage capacity') }
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(namespace_storage_limit: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when feature flag is disabled for namespace' do
      before do
        stub_feature_flags(namespace_storage_limit: { enabled: false, thing: namespace })
      end

      it { is_expected.to be_nil }
    end
  end

  describe '#usage_message' do
    let(:current_size) { 60.megabytes }

    subject { model.usage_message }

    before do
      stub_application_setting(namespace_storage_size_limit: 100)
    end

    it 'returns current usage information' do
      message = subject

      expect(message).to include("60 MB of 100 MB")
      expect(message).to include("60%")
    end

    context 'when not admin of namespace' do
      let(:namespace) { other_namespace }

      it { is_expected.to be_nil }
    end

    context 'when feature flag is disabled' do
      before do
        stub_feature_flags(namespace_storage_limit: false)
      end

      it { is_expected.to be_nil }
    end

    context 'when feature flag is disabled for namespace' do
      before do
        stub_feature_flags(namespace_storage_limit: { enabled: false, thing: namespace })
      end

      it { is_expected.to be_nil }
    end
  end
end
