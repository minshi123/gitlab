# frozen_string_literal: true

require 'spec_helper'

describe ExpirationPolicyContainerRepositoryWorker, :clean_gitlab_redis_shared_state do
  let(:repository) { create(:container_repository) }
  let(:project) { repository.project }
  let(:user) { project.owner }
  let(:params) { { container_expiration_policy: true } }

  subject { described_class.new }

  describe '#perform' do
    let(:service) { instance_double(Projects::ContainerRepository::CleanupTagsService) }

    before do
      allow(Projects::ContainerRepository::CleanupTagsService).to receive(:new)
        .with(project, nil, params).and_return(service)
    end

    it 'executes the destroy service' do
      expect(service).to receive(:execute)

      subject.perform(repository.id, params)
    end

    it 'does not raise error when repository could not be found' do
      expect do
        subject.perform(-1, params)
      end.not_to raise_error
    end

    context 'without container_expiration_policy param' do
      let(:params) { {} }

      it 'logs an error when not run with the correct param but does not halt execution' do
        expect(Gitlab::ErrorTracking).to receive(:track_exception)

        expect do
          subject.perform(repository.id, params)
        end.not_to raise_error
      end
    end
  end
end
