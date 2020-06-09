# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe ::Gitlab::Ci::Config::Entry::Parallel::Matrix do
  subject(:matrix) { described_class.new(config) }

  describe 'validations' do
    before do
      matrix.compose!
    end

    context 'when entry config value is correct' do
      let(:config) do
        [
          { 'VAR_1' => [1, 2, 3], 'VAR_2' => [4, 5, 6] },
          { 'VAR_3' => %w[a b], 'VAR_4' => %w[c d] }
        ]
      end

      describe '#valid?' do
        it { is_expected.to be_valid }
      end
    end

    context 'when config value has wrong type' do
      let(:config) { {} }

      describe '#valid?' do
        it { is_expected.not_to be_valid }
      end

      describe '#errors' do
        it 'returns error about incorrect type' do
          expect(matrix.errors)
            .to include('matrix config should be an array of hashes')
        end
      end
    end
  end

  describe '.compose!' do
    shared_examples 'entry with descendant nodes' do
      describe '#descendants' do
        it 'creates valid descendant nodes' do
          expect(matrix.descendants.count).to eq 2
          expect(matrix.descendants)
            .to all(be_an_instance_of(::Gitlab::Ci::Config::Entry::Parallel::Variables))
        end
      end
    end

    context 'when valid job entries composed' do
      let(:config) do
        [
          { 'VAR_1' => [1, 2, 3], 'VAR_2' => [4, 5, 6] },
          { 'VAR_3' => %w[a b], 'VAR_4' => %w[c d] }
        ]
      end

      before do
        matrix.compose!
      end

      describe '#value' do
        it 'returns key value' do
          expect(matrix.value).to match(
            [
              { 'VAR_1' => %w[1 2 3], 'VAR_2' => %w[4 5 6] },
              { 'VAR_3' => %w[a b], 'VAR_4' => %w[c d] }
            ]
          )
        end
      end

      it_behaves_like 'entry with descendant nodes'
    end

    context 'with empty config' do
      let(:config) do
        []
      end

      before do
        matrix.compose!
      end

      describe '#value' do
        it 'returns empty value' do
          expect(matrix.value).to eq([])
        end
      end
    end
  end
end
