# frozen_string_literal: true

require 'spec_helper'

describe Resolvers::SecurityDashboard::ProjectsResolver do
  include GraphqlHelpers

  describe '#resolve' do
    subject { resolve(described_class, obj: object, ctx: { current_user: user }) }

    let_it_be(:project) { create(:project) }
    let_it_be(:user) { create(:user, security_dashboard_projects: [project]) }

    context 'when provided object is InstanceSecurityDashboard' do
      let(:object) { InstanceSecurityDashboard.new(user) }

      it 'returns list of projects' do
        is_expected.to eq(object.projects)
      end
    end

    context 'when object is not provided' do
      let(:object) { nil }

      it 'returns nil' do
        is_expected.to be_nil
      end
    end
  end
end
