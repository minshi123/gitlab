# frozen_string_literal: true

require 'spec_helper'

describe TerraformStateUploader do
  subject { terraform_state.file }

  let(:terraform_state) { create(:terraform_state, :with_file) }

  before do
    stub_uploads_object_storage
  end

  describe '#filename' do
    it 'contains the ID of the terraform state record' do
      expect(subject.filename).to include(terraform_state.id.to_s)
    end
  end

  describe '#key' do
    before do
      allow(OpenSSL::HMAC).to receive(:digest).and_call_original
    end

    it 'creates a digest with a secret key and the project id' do
      subject

      expect(OpenSSL::HMAC)
        .to have_received(:digest)
        .with("SHA256", Gitlab::Application.secrets.db_key_base, terraform_state.project_id.to_s)
    end
  end
end
