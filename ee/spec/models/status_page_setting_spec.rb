# frozen_string_literal: true

require 'spec_helper'

describe StatusPageSetting do
  describe 'associations' do
    it { is_expected.to belong_to(:project) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:aws_s3_bucket_name) }
    it { is_expected.to validate_presence_of(:aws_region) }
    it { is_expected.to validate_presence_of(:aws_access_key) }
    it { is_expected.to validate_presence_of(:encrypted_aws_secret_key) }
  end

  describe 'attribute encryption' do
    subject(:status_page_setting) { create(:status_page_setting, aws_secret_key: 'super-secret') }

    context 'token' do
      it 'encrypts original value into encrypted_token attribute' do
        expect(status_page_setting.encrypted_aws_secret_key).not_to be_nil
      end

      it 'locks access to raw value in private method', :aggregate_failures do
        expect { status_page_setting.aws_secret_key }.to raise_error(NoMethodError, /private method .aws_secret_key. called/)
        expect(status_page_setting.send(:aws_secret_key)).to eql('super-secret')
      end

      it 'prevents overriding token value with its encrypted or masked version', :aggregate_failures do
        expect { status_page_setting.update(aws_secret_key: status_page_setting.encrypted_aws_secret_key) }.not_to change { status_page_setting.reload.send(:aws_secret_key) }
        expect { status_page_setting.update(aws_secret_key: status_page_setting.masked_aws_secret_key) }.not_to change { status_page_setting.reload.send(:aws_secret_key) }
      end
    end
  end
end
