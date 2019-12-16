# frozen_string_literal: true

require 'rake_helper'

describe 'gitlab:secrets namespace rake task' do
  before do
    Rake.application.rake_require 'tasks/gitlab/secrets'
  end

  describe 'check' do
    subject(:rake_task) { run_rake_task('gitlab:secrets:check') }

    context 'when encrypted attributes are properly set' do
      let!(:user) { create(:user, otp_secret: "test") }
      let!(:group) { create(:group, runners_token: "test") }

      it 'detects decryptable secrets' do
        expect { rake_task }.to(
          output(/User: 0 bad, 0 fixed, 1 total.*Group: 0 bad, 0 fixed, 1 total/m).to_stdout)
      end
    end

    context 'when attr_encrypted values are not decrypting' do
      let!(:user) { create(:user, encrypted_otp_secret: "invalid") }

      it 'marks undecryptable values as bad' do
        user.encrypted_otp_secret = "invalid"
        user.save!

        expect { rake_task }.to(
          output(/User: 1 bad, 0 fixed, 1 total/).to_stdout)
      end
    end

    context 'when TokenAuthenticatable values are not decrypting' do
      let!(:group) { create(:group, runners_token: "test") }

      it 'marks undecryptable values as bad' do
        group.runners_token_encrypted = "invalid"
        group.save!

        expect { rake_task }.to(
          output(/Group: 1 bad, 0 fixed, 1 total/).to_stdout)
      end
    end
  end

  describe 'fix' do
    subject(:rake_task) { run_rake_task('gitlab:secrets:fix') }

    context 'when encrypted attributes are properly set' do
      let!(:user) { create(:user, otp_secret: "test") }
      let!(:group) { create(:group, runners_token: "test") }

      it 'detects and does not fix decryptable secrets' do
        expect { rake_task }.to(
          output(/User: 0 bad, 0 fixed, 1 total.*Group: 0 bad, 0 fixed, 1 total/m).to_stdout)
      end
    end

    context 'when attr_encrypted values are not decrypting' do
      let!(:user) { create(:user, encrypted_otp_secret: "invalid") }

      it 'detect and fixes undecryptable values' do
        user.encrypted_otp_secret = "invalid"
        user.save!

        expect { rake_task }.to(
          output(/User: 1 bad, 1 fixed, 1 total/).to_stdout)
        expect(user.otp_secret).to eq("")
      end
    end

    context 'when TokenAuthenticatable values are not decrypting' do
      let!(:group) { create(:group, runners_token: "test") }

      it 'detects and fixes undecryptable values' do
        group.runners_token_encrypted = "invalid"
        group.save!

        expect { rake_task }.to(
          output(/Group: 1 bad, 1 fixed, 1 total/).to_stdout)
        expect(user.runners_token).to eq("")
      end
    end
  end
end
