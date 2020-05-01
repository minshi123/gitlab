# frozen_string_literal: true

RSpec.shared_examples 'measurable service' do |feature_flag|
  context 'when measurement is enabled' do
    let(:logger) { double(:logger) }
    let!(:measuring) { Gitlab::Utils::Measuring.new(base_log_data) }

    before do
      allow(logger).to receive(:info)
      stub_feature_flags(feature_flag => true)
    end

    it 'measure service execution with Gitlab::Utils::Measuring', :aggregate_failures do
      expect(Gitlab::Utils::Measuring).to receive(:new).with(base_log_data).and_return(measuring)
      expect(measuring).to receive(:with_measuring).and_call_original
    end
  end

  context 'when measurement is disabled' do
    it 'does not measure service execution' do
      stub_feature_flags(feature_flag => false)

      expect(Gitlab::Utils::Measuring).not_to receive(:new)
    end
  end
end
