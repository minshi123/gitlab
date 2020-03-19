# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::JwtAuth do
  let(:namespace) { build_stubbed(:namespace) }
  let(:project) { build_stubbed(:project, namespace: namespace) }
  let(:user) { build_stubbed(:user) }
  let(:build) do
    build_stubbed(
      :ci_build,
      project: project,
      user: user,
      ref: 'auto-deploy-2020-03-19',
      environment: 'staging/$CI_COMMIT_REF_NAME'
    )
  end

  describe '#payload' do
    subject(:payload) { described_class.new(build).payload(ttl: 60) }

    it 'has correct values for the standard JWT attributes' do
      Timecop.freeze do
        now = Time.now.to_i

        aggregate_failures do
          expect(payload[:iss]).to eq(Settings.gitlab.host)
          expect(payload[:iat]).to eq(now)
          expect(payload[:exp]).to eq(now + 60)
          expect(payload[:sub]).to eq(project.id.to_s)
        end
      end
    end

    it 'has correct values for the custom attributes' do
      aggregate_failures do
        expect(payload[:uid]).to eq(user.id.to_s)
        expect(payload[:pid]).to eq(project.id.to_s)
        expect(payload[:jid]).to eq(build.id.to_s)
        expect(payload[:ref]).to eq(build.ref)
        expect(payload[:env]).to eq("staging/$CI_COMMIT_REF_NAME")
      end
    end

    describe 'namespace id' do
      context "users" do
        it 'has "user:" prefix' do
          expect(payload[:nid]).to eq("user:#{namespace.id}")
        end
      end

      context "groups" do
        let(:namespace) { build_stubbed(:namespace, type: 'Group') }

        it 'has "group:" prefix' do
          expect(payload[:nid]).to eq("group:#{namespace.id}")
        end
      end
    end

    describe 'ref type' do
      context 'branches' do
        it 'is "branch"' do
          expect(build).to receive(:branch?).and_return(true)

          expect(payload[:ref_type]).to eq('branch')
        end
      end

      context 'tags' do
        it 'is "tag"' do
          expect(build).to receive(:branch?).and_return(false)
          expect(build).to receive(:tag?).and_return(true)

          expect(payload[:ref_type]).to eq('tag')
        end
      end

      context 'merge requests' do
        it 'is "mr"' do
          expect(build).to receive(:branch?).and_return(false)
          expect(build).to receive(:tag?).and_return(false)
          expect(build).to receive(:merge_request?).and_return(true)

          expect(payload[:ref_type]).to eq('mr')
        end
      end
    end

    describe 'ref_protection' do
      let(:project) { create(:project) }

      it 'is empty list if ref is not protected' do
        expect(payload[:ref_protection]).to be_empty
      end

      context 'when ref is protected branch' do
        let(:project) { create(:project) }
        let!(:not_match) { create(:protected_branch, project: project, name: 'auto-deploy') }
        let!(:match_1) { create(:protected_branch, project: project,  name: 'auto-deploy-*') }
        let!(:match_2) { create(:protected_branch, project: project,  name: 'auto-deploy-2020-*') }

        it 'has the list of protected branch wildcards' do
          _unrelated = create(:protected_branch,  name: 'auto-deploy-2020-03-*')

          expect(build).to receive(:branch?).and_return(true)

          expect(payload[:ref_protection]).to contain_exactly('auto-deploy-*', 'auto-deploy-2020-*')
        end
      end

      context 'when ref is protected tag' do
        let!(:not_match) { create(:protected_tag, project: project, name: 'auto-deploy') }
        let!(:match_1) { create(:protected_tag, project: project,  name: 'auto-deploy-*') }
        let!(:match_2) { create(:protected_tag, project: project,  name: 'auto-deploy-2020-*') }

        it 'has the list of protected tag wildcards' do
          _unrelated = create(:protected_tag,  name: 'auto-deploy-2020-03-*')

          expect(build).to receive(:branch?).and_return(false)
          expect(build).to receive(:tag?).and_return(true)

          expect(payload[:ref_protection]).to contain_exactly('auto-deploy-*', 'auto-deploy-2020-*')
        end
      end

      context 'when ref is protected default branch' do
        it 'includes the default branch' do
          expect(build).to receive(:branch?).and_return(true)
          expect(project).to receive(:default_branch_protected?).and_return(true)
          allow(project).to receive(:default_branch).and_return('auto-deploy-2020-03-19')

          expect(payload[:ref_protection]).to contain_exactly('auto-deploy-2020-03-19')
        end
      end

      xcontext 'when ref is merge request'
    end
  end

  describe '.jwt_for_build' do
    let(:rsa_key) { OpenSSL::PKey::RSA.new(Rails.application.secrets.openid_connect_signing_key) }

    it 'generates JWT for the given job with ttl equal to build timeout' do
      expect(build).to receive(:metadata_timeout).and_return(3_600)

      jwt = described_class.jwt_for_build(build)
      payload, _algorithm = JWT.decode(jwt, rsa_key.public_key, true, { algorithm: 'RS256' })
      ttl = payload["exp"] - payload["iat"]

      expect(ttl).to eq(3_600)
    end

    it 'generates JWT for the given job with default ttl if build timeout is not set' do
      expect(build).to receive(:metadata_timeout).and_return(nil)

      jwt = described_class.jwt_for_build(build)
      payload, _algorithm = JWT.decode(jwt, rsa_key.public_key, true, { algorithm: 'RS256' })
      ttl = payload["exp"] - payload["iat"]

      expect(ttl).to eq(60)
    end
  end
end
