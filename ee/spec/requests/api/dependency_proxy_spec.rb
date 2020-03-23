# frozen_string_literal: true

require 'spec_helper'

describe API::DependencyProxy do
  let_it_be(:user) { create(:admin) }
  let_it_be(:group) { create(:group) }

  before do
    enable_feature
    stub_licensed_features(dependency_proxy: true)
  end

  describe 'DELETE /groups/:id/dependency_proxy/cache' do
    subject { delete api("/groups/#{group.id}/dependency_proxy/cache", user) }

    context 'a non-admin' do
      let(:user) { create(:user) }

      before do
        group.add_maintainer(user)
      end

      it 'returns forbidden' do
        subject

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end

    context 'an admin user' do
      it 'returns ok' do
        subject

        expect(response).to have_gitlab_http_status(:no_content)
      end
    end
  end

  def enable_feature
    allow(Gitlab.config.dependency_proxy).to receive(:enabled).and_return(true)
  end
end
