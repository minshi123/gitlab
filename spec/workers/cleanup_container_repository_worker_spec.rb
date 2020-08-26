# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CleanupContainerRepositoryWorker, :clean_gitlab_redis_shared_state do
  let_it_be(:repository) { create(:container_repository) }
  let(:project) { repository.project }
  let(:user) { project.owner }
  let(:user_id) { user.id }
  let(:repository_id) { repository.id }
  let(:params) { {} }
  let(:job_args) { [user_id, repository_id, params] }

  describe '#perform' do
    let(:service) { instance_double(Projects::ContainerRepository::CleanupTagsService) }
    let(:manifest) { { 'tags' => %w(A B C) } }

    subject { described_class.new.perform(*job_args) }

    context 'bulk delete api' do
      let(:params) { { key: 'value', 'name_regex_delete' => '.*', 'container_expiration_policy' => false } }

      it 'executes the destroy service' do
        expect(Projects::ContainerRepository::CleanupTagsService).to receive(:new)
          .with(project, user, params.merge('container_expiration_policy' => false))
          .and_return(service)

        expect(service).to receive(:execute)

        subject
      end

      it_behaves_like 'an idempotent worker' do
        before do
          allow_next_instance_of(ContainerRegistry::Client) do |client|
            allow(client).to receive(:supports_tag_delete?).and_return(true)
            allow(client).to receive(:repository_tags).and_return(manifest)
            allow(client).to receive(:delete_if_exists).and_return(true)
          end
        end
      end

      context 'with an invalid user_id' do
        let(:user_id) { -1 }

        it { expect { subject }.not_to raise_error }
      end

      context 'with an invalid repository id' do
        let(:repository_id) { -1 }

        it { expect { subject }.not_to raise_error }
      end
    end

    context 'container expiration policy' do
      let(:params) { { key: 'value', 'name_regex_delete' => '.*', 'container_expiration_policy' => true } }

      it 'executes the destroy service' do
        expect(Projects::ContainerRepository::CleanupTagsService).to receive(:new)
          .and_return(service)

        expect(service).to receive(:execute)

        subject
      end

      it_behaves_like 'an idempotent worker' do
        before do
          allow_next_instance_of(ContainerRegistry::Client) do |client|
            allow(client).to receive(:supports_tag_delete?).and_return(true)
            allow(client).to receive(:repository_tags).and_return(manifest)
            allow(client).to receive(:delete_if_exists).and_return(true)
          end
        end
      end
    end

    context 'with feature flag container_registry_expiration_policies_throttling enabled' do
      let(:params) { { 'container_expiration_policy' => true } }

      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: true)
        allow(Projects::ContainerRepository::CleanupTagsService).to receive(:new).and_return(service)
        allow(service).to receive(:execute)
      end

      context 'without a jids cache key' do
        it 'do not access redis' do
          Sidekiq.redis do |redis|
            expect(redis).not_to receive(:lrem)
          end

          subject
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
          end
        end

        after do
          Sidekiq.redis do |redis|
            expect(redis.llen(cache_key)).to eq(expected_cache_size)
          end
        end

        it 'removes the jid from the cache' do
          allow_next_instance_of(CleanupContainerRepositoryWorker) do |worker|
            allow(worker).to receive(:jid).and_return(jid)
          end

          Sidekiq.redis do |redis|
            expect(redis).to receive(:lrem).and_call_original
          end

          subject
        end

        context 'not containing the jid' do
          let(:expected_cache_size) { 1 }

          it 'does not remove the other jids from the cache' do
            allow_next_instance_of(CleanupContainerRepositoryWorker) do |worker|
              allow(worker).to receive(:jid).and_return(5555)
            end

            Sidekiq.redis do |redis|
              expect(redis).to receive(:lrem).and_call_original
            end

            subject
          end
        end
      end
    end
  end
end
