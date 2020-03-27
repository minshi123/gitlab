# frozen_string_literal: true

RSpec.shared_examples 'editing snippets with binary blob' do
  let(:binary) { nil }

  before do
    sign_in(user)

    allow_next_instance_of(Blob) do |blob|
      allow(blob).to receive(:binary?).and_return(binary)
    end

    subject
  end

  subject { get :edit, params: params }

  context 'when blob is text' do
    it 'responds with status 200' do
      expect(response).to have_gitlab_http_status(:ok)
    end
  end

  context 'when blob is binary' do
    let(:binary) { true }

    it 'redirects away' do
      expect(response).to redirect_to(path)
    end
  end
end
