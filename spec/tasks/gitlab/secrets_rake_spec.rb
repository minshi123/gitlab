# frozen_string_literal: true

require 'rake_helper'

describe 'gitlab:secrets namespace rake task' do
  before do
    Rake.application.rake_require 'tasks/gitlab/secrets'
  end

  describe 'check' do
    let!(:user) { create(:user, otp_secret: "test") }
    let!(:group) { create(:group, runners_token: "test") }
    subject(:rake_task) { run_rake_task('gitlab:secrets:check') }

    context 'when encrypted attributes are properly set' do
      it 'detects decryptable secrets' do
        expect { rake_task }.to(
          output(/User: 0 bad, 0 fixed, 1 total.*Group: 0 bad, 0 fixed, 1 total/m).to_stdout)
      end
    end

    context 'when attr_encrypted values are not decrypting' do
      it 'marks undecryptable values as bad' do
        user.encrypted_otp_secret = "invalid"
        user.save!

        expect { rake_task }.to(
          output(/User: 1 bad, 0 fixed, 1 total/).to_stdout)
      end
    end

    context 'when TokenAuthenticatable values are not decrypting' do
      it 'marks undecryptable values as bad' do
        group.runners_token_encrypted = "invalid"
        group.save!

        expect { rake_task }.to(
          output(/Group: 1 bad, 0 fixed, 1 total/).to_stdout)
      end
    end
  end

  describe 'fix' do
    let!(:user) { create(:user, otp_secret: "test") }
    let!(:group) { create(:group, runners_token: "test") }
    subject(:rake_task) { run_rake_task('gitlab:secrets:fix') }

    context 'when encrypted attributes are properly set' do
      it 'detects and does not fix decryptable secrets' do
        expect { rake_task }.to(
          output(/User: 0 bad, 0 fixed, 1 total.*Group: 0 bad, 0 fixed, 1 total/m).to_stdout)
      end
    end

    context 'when attr_encrypted values are not decrypting' do
      it 'detect and fixes undecryptable values' do
        user.encrypted_otp_secret = "invalid"
        user.save!

        expect { rake_task }.to(
          output(/User: 1 bad, 1 fixed, 1 total/).to_stdout)

        user.reload
        expect(user.otp_secret).to eq("")
      end
    end

    context 'when TokenAuthenticatable values are not decrypting' do
      context 'when the unencrypted value is still present' do
        it 'detects and fixes undecryptable values using encrypted value' do
          group.runners_token_encrypted = "invalid"
          group.save!

          expect { rake_task }.to(
            output(/Group: 1 bad, 1 fixed, 1 total/).to_stdout)

          group.reload
          expect(group.runners_token).to eq("test")
        end
      end

      context 'when the unencrypted value is not present' do
        it 'detects and clears undecryptable values' do
          group.runners_token_encrypted = "invalid"
          group.runners_token = nil
          group.save!

          expect { rake_task }.to(
            output(/Group: 1 bad, 1 fixed, 1 total/).to_stdout)

          group.reload
          expect(group.runners_token).not_to eq("test") # actually a new randomly generated token
        end
      end
    end
  end
end
