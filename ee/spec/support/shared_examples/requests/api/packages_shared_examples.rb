# frozen_string_literal: true

RSpec.shared_examples 'works with deploy token authentication' do
  context 'deploy token' do
    let(:headers) { build_basic_auth_header(deploy_token.username, deploy_token.token) }

    subject { get api(url), headers: headers }

    context 'valid token' do
      it_behaves_like 'returning response status', :ok
    end

    context 'invalid token' do
      let(:headers) { build_basic_auth_header(deploy_token.username, 'invalid') }

      it_behaves_like 'returning response status', :ok
    end
  end
end