# frozen_string_literal: true

require 'spec_helper'

describe OperationsHelper do
  describe '#status_page_settings_data' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { create(:project, :private) }
    let_it_be(:status_page_setting) { project.build_status_page_setting }

    subject { helper.status_page_settings_data }

    before do
      helper.instance_variable_set(:@project, project)
      allow(helper).to receive(:status_page_setting) { status_page_setting }
      allow(helper).to receive(:current_user) { user }
      allow(helper)
        .to receive(:can?).with(user, :admin_operations, project) { true }
    end

    context 'setting does not exist' do

      it 'returns the correct values' do
        expect(subject).to eq(
          'user-can-enable-status-page' => 'true',
          'setting-enabled' => 'false',
          'setting-aws-access-key' => nil,
          'setting-masked-aws-secret-key' => nil,
          'setting-aws-region' => nil,
          'setting-aws-s3-bucket-name' => nil
        )
      end

      context 'user does not have permission' do
        before do
          allow(helper)
            .to receive(:can?).with(user, :admin_operations, project) { false }
        end

        it 'returns the correct values' do
          expect(subject).to eq(
            'user-can-enable-status-page' => 'false',
            'setting-enabled' => 'false',
            'setting-aws-access-key' => nil,
            'setting-masked-aws-secret-key' => nil,
            'setting-aws-region' => nil,
            'setting-aws-s3-bucket-name' => nil
          )
        end
      end
    end

    context 'setting exists' do
      let(:status_page_setting) { create(:status_page_setting) }

      it 'returns the correct values' do
        expect(subject).to eq(
          'user-can-enable-status-page' => 'true',
          'setting-enabled' => status_page_setting.enabled.to_s,
          'setting-aws-access-key' => status_page_setting.aws_access_key,
          'setting-masked-aws-secret-key' => status_page_setting.masked_aws_secret_key,
          'setting-aws-region' => status_page_setting.aws_region,
          'setting-aws-s3-bucket-name' => status_page_setting.aws_s3_bucket_name
        )
      end
    end
  end
end
