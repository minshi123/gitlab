# frozen_string_literal: true

require 'spec_helper'

describe ContainerRegistry::EventsHandler do
  include ::EE::GeoHelpers

  describe '#execute' do
    subject { described_class.new([event]).execute }

    let(:container_repository) { create(:container_repository) }
    let(:event_target_for_push) do
      { 'mediaType' => 'application/vnd.docker.distribution.manifest.v2+json', 'repository' => container_repository.path }
    end
    let(:event_target_for_delete) do
      { 'tag' => 'latest', 'repository' => container_repository.path }
    end

    let_it_be(:primary_node)   { create(:geo_node, :primary) }
    let_it_be(:secondary_node) { create(:geo_node) }

    before do
      stub_current_geo_node(primary_node)
    end

    RSpec.shared_examples 'creating a geo event' do
      it 'creates geo event' do
        expect { subject }
          .to change { ::Geo::ContainerRepositoryUpdatedEvent.count }.by(1)
      end
    end

    RSpec.shared_examples 'not creating a geo event' do
      it 'does not create geo event' do
        expect { subject }
          .not_to change { ::Geo::ContainerRepositoryUpdatedEvent.count }
      end
    end

    RSpec.shared_examples 'tracking event with action' do |action|
      it 'creates a tracking event' do
        expect(::Gitlab::Tracking).to receive(:event).with('container_registry:notification', action)

        subject
      end
    end

    RSpec.shared_examples 'not tracking event' do |action|
      it 'does not create a tracking event' do
        expect(::Gitlab::Tracking).not_to receive(:event)

        subject
      end
    end

    context 'with create repository event' do
      let(:event) do
        {
          'action' => 'push',
          'target' => {
            'mediaType' => 'application/vnd.docker.distribution.manifest.v2+json',
            'repository' => 'foo/bar'
          }
        }
      end

      it_behaves_like 'not creating a geo event'
      it_behaves_like 'tracking event with action', 'create_repository'
    end

    context 'with push repository event' do
      let(:event) do
        {
          'action' => 'push',
          'target' => {
            'mediaType' => 'application/vnd.docker.distribution.manifest.v2+json',
            'repository' => container_repository.path
          }
        }
      end

      it_behaves_like 'creating a geo event'
      it_behaves_like 'tracking event with action', 'push_repository'
    end

    context 'with push tag event' do
      let(:event) do
        {
          'action' => 'push',
          'target' => {
            'mediaType' => 'application/vnd.docker.distribution.manifest.v2+json',
            'repository' => container_repository.path,
            'tag' => 'latest'
          }
        }
      end

      it_behaves_like 'creating a geo event'
      it_behaves_like 'tracking event with action', 'push_tag'
    end

    context 'with delete tag event' do
      let(:event) do
        {
          'action' => 'delete',
          'target' => {
            'mediaType' => 'application/vnd.docker.distribution.manifest.v2+json',
            'repository' => container_repository.path,
            'tag' => 'latest'
          }
        }
      end

      it_behaves_like 'creating a geo event'
      it_behaves_like 'tracking event with action', 'delete_tag'
    end

    context 'with pull event' do
      let(:event) { { 'action' => 'pull', 'target' => {} } }

      it_behaves_like 'not creating a geo event'
      it_behaves_like 'not tracking event'
    end
  end
end
