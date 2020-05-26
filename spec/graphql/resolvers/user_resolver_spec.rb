# frozen_string_literal: true

require 'spec_helper'

describe Resolvers::UserResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:user) { create(:user) }

    context 'when neither an ID and username is provided' do
      subject { resolve(described_class, args: {}) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end
    end

    context 'when both an ID and username is provided' do
      subject { resolve(described_class, args: { id: user.to_global_id, username: user.username }) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end
    end

    context 'by username' do
      it 'returns the correct user' do
        result = resolve(described_class, args: { username: user.username })
        expect(result).to eq(user)
      end
    end

    context 'by ID' do
      it 'returns the correct user' do
        result = resolve(described_class, args: { id: user.to_global_id })
        expect(result).to eq(user)
      end

      it 'raises an error when the user does not exist' do
        expect { resolve(described_class, args: { id: 'NOTAVALIDID' }) }.to raise_error(Gitlab::Graphql::Errors::ArgumentError)
      end
    end
  end
end
