# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CleanupContainerRepositoryWorker, :clean_gitlab_redis_shared_state do
  let(:repository) { create(:container_repository) }
  let(:project) { repository.project }
  let(:user) { project.owner }

  subject { described_class.new }

  describe '#perform' do
    let(:service) { instance_double(Projects::ContainerRepository::CleanupTagsService) }

    context 'bulk delete api' do
      let(:params) { { key: 'value', 'container_expiration_policy' => false } }

      it 'executes the destroy service' do
        expect(Projects::ContainerRepository::CleanupTagsService).to receive(:new)
          .with(project, user, params.merge('container_expiration_policy' => false))
          .and_return(service)
        expect(service).to receive(:execute)

        subject.perform(user.id, repository.id, params)
      end

      it 'does not raise error when user could not be found' do
        expect do
          subject.perform(-1, repository.id, params)
        end.not_to raise_error
      end

      it 'does not raise error when repository could not be found' do
        expect do
          subject.perform(user.id, -1, params)
        end.not_to raise_error
      end
    end

    context 'container expiration policy' do
      let(:params) { { key: 'value', 'container_expiration_policy' => true } }

      it 'executes the destroy service' do
        expect(Projects::ContainerRepository::CleanupTagsService).to receive(:new)
          .with(project, nil, params.merge('container_expiration_policy' => true))
          .and_return(service)

        expect(service).to receive(:execute)

        subject.perform(nil, repository.id, params)
      end
    end

    context 'with feature flag container_registry_expiration_policies_throttling enabled' do
      let(:params) { { 'container_expiration_policy' => true } }

      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: true)
        allow(Projects::ContainerRepository::CleanupTagsService).to receive(:new).and_return(service)
        expect(service).to receive(:execute)
      end

      context 'without a jids cache key' do
        it 'do not access redis' do
          Sidekiq.redis do |redis|
            expect(redis).not_to receive(:lrem)
          end

          subject.perform(nil, repository.id, params)
        end
      end

      context 'with a jids cache key' do
        let(:cache_key) { 'jids' }
        let(:jid) { 1234567 }
        let(:params) { { 'container_expiration_policy' => true, 'jids_cache_key' => cache_key } }
        let(:expected_cache_size) { 0 }

        before do
          Sidekiq.redis do |redis|
            redis.rpush(cache_key, jid)
            expect(redis).to receive(:lrem).and_call_original
          end
        end

        after do
          Sidekiq.redis do |redis|
            expect(redis.llen(cache_key)).to eq(expected_cache_size)
          end
        end

        it 'removes the jid from the cache' do
          expect(subject).to receive(:jid).and_return(jid)

          subject.perform(nil, repository.id, params)
        end

        context 'not containing the jid' do
          let(:expected_cache_size) { 1 }

          it 'does not remove the other jids from the cache' do
            expect(subject).to receive(:jid).and_return(5555)

            subject.perform(nil, repository.id, params)
          end
        end
      end
    end
  end
end
