# frozen_string_literal: true

require 'spec_helper'

describe Resolvers::SecurityDashboardResolver do
  include GraphqlHelpers

  describe '#resolve' do
    subject { resolve(described_class, ctx: { current_user: current_user }) }

    let_it_be(:user) { create(:user) }

    context 'when user is logged in' do
      let(:current_user) { user }

      it 'returns instance of InstanceSecurityDashboard' do
        is_expected.to be_a(InstanceSecurityDashboard)
      end
    end

    context 'when user is not logged in' do
      let(:current_user) { nil }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end
end
