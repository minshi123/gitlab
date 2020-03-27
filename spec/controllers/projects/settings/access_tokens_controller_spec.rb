# frozen_string_literal: true

require('spec_helper')

describe Projects::Settings::AccessTokensController do
  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project) }

  before do
    project.add_maintainer(user)
    sign_in(user)
  end

  shared_examples 'feature unavailability' do
    context 'when flag is disabled' do
      before do
        stub_feature_flags(resource_access_token: false)
      end

      it { is_expected.to be_not_found }
    end

    context 'when environment is Gitlab.com' do
      before do
        allow(Gitlab).to receive(:com?).and_return(true)
      end

      it { is_expected.to be_not_found }
    end
  end

  describe '#index' do
    subject { get :index, params: { namespace_id: project.namespace, project_id: project } }

    it_behaves_like 'feature unavailability'

    context 'when feature is available' do
      let_it_be(:bot_user) { create(:user, :project_bot) }
      let_it_be(:active_project_access_token) { create(:personal_access_token, user: bot_user) }
      let_it_be(:inactive_project_access_token) { create(:personal_access_token, :revoked, user: bot_user) }

      before do
        enable_feature
        project.add_maintainer(bot_user)
      end

      it "retrieves active project access tokens" do
        subject

        expect(assigns(:active_project_access_tokens)).to include(active_project_access_token)
      end

      it "retrieves inactive project access tokens" do
        subject

        expect(assigns(:inactive_project_access_tokens)).to include(inactive_project_access_token)
      end

      it "lists all available scopes" do
        subject

        expect(assigns(:scopes)).to eq(Gitlab::Auth.resource_bot_scopes)
      end
    end
  end

  describe '#create' do
    subject { post :create, params: { namespace_id: project.namespace, project_id: project }.merge(project_access_token: access_token_params) }

    let(:access_token_params) { {} }

    it_behaves_like 'feature unavailability'

    context 'when feature is available' do
      let(:access_token_params) { { name: 'Nerd bot', scopes: [:api], expires_at: (Date.today + 1.month).to_s } }

      before do
        enable_feature
      end

      it "creates project access tokens" do
        subject

        expect(response.flash[:notice]).to match(/\AYour new project access token has been created./i)
      end

      it { expect { subject }.to change { User.count }.by(1) }
      it { expect { subject }.to change { PersonalAccessToken.count }.by(1) }
    end
  end

  describe '#revoke' do
    subject { put :revoke, params: { namespace_id: project.namespace, project_id: project, id: project_access_token } }

    let_it_be(:bot_user) { create(:user, :project_bot) }
    let_it_be(:project_access_token) { create(:personal_access_token, user: bot_user) }

    before do
      project.add_maintainer(bot_user)
    end

    it_behaves_like 'feature unavailability'
  end

  def enable_feature
    allow(Gitlab).to receive(:com?).and_return(false)
    stub_feature_flags(resource_access_token: true)
  end
end
