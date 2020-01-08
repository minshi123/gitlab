# frozen_string_literal: true

require 'spec_helper'

describe ChatMessage::BaseMessage do
  describe '#format' do
    subject { described_class.new(args).send(:format, string) }

    let(:args) { { project_url: 'https://gitlab-domain.com' } }

    context 'without relative links' do
      let(:string) { 'Just another *markdown* message' }

      it { is_expected.to eq(string) }
    end

    context 'with relative links' do
      let(:string) { 'Check this out ![Screenshot1](/uploads/Screenshot1.png)' }

      it { is_expected.to eq('Check this out https://gitlab-domain.com/uploads/Screenshot1.png') }
    end
  end
end
