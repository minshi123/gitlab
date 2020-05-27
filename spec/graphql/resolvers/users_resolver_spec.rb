# frozen_string_literal: true

require 'spec_helper'

describe Resolvers::UsersResolver do
  include GraphqlHelpers

  let_it_be(:user1) { create(:user) }
  let_it_be(:user2) { create(:user) }

  describe '#resolve' do
    context 'when no arguments are passed' do
      it 'returns all users' do
        expect(resolve_users).to contain_exactly(user1, user2)
      end
    end

    context 'when a set of IDs is passed' do
      it 'returns those users' do
        expect(
          resolve_users(ids: [user1.to_global_id.to_s, user2.to_global_id.to_s])
        ).to contain_exactly(user1, user2)
      end
    end
  end

  def resolve_users(args = {})
    resolve(described_class, args: args)
  end
end
