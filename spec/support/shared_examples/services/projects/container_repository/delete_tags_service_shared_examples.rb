# frozen_string_literal: true

RSpec.shared_examples 'deleting container tags' do
  context 'without permissions' do
    it { is_expected.to include(status: :error) }
  end

  context 'with permissions' do
    before do
      project.add_developer(user)
    end

    context 'when the registry supports fast delete' do
      context 'and the feature is enabled' do
        before do
          allow(repository.client).to receive(:supports_tag_delete?).and_return(true)
        end

        context 'with tags to delete' do
          let_it_be(:tags) { %w[A Ba] }

          it_behaves_like 'deleting with fast delete container tags', %w[A Ba]

          it 'succeeds when tag delete returns 404' do
            stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/tags/reference/A")
              .to_return(status: 200, body: "")

            stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/tags/reference/Ba")
              .to_return(status: 404, body: "")

            is_expected.to include(status: :success)
          end

          context 'with failures' do
            context 'when the delete request fails' do
              before do
                stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/tags/reference/A")
                .to_return(status: 500, body: "")

                stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/tags/reference/Ba")
                .to_return(status: 500, body: "")
              end

              it { is_expected.to include(status: :error) }
            end
          end
        end

        context 'when no params are specified' do
          let_it_be(:params) { {} }

          it 'does not remove anything' do
            expect_any_instance_of(ContainerRegistry::Client).not_to receive(:delete_repository_tag_by_name)

            is_expected.to include(status: :error)
          end
        end

        context 'with empty tags' do
          let_it_be(:tags) { [] }

          it 'does not remove anything' do
            expect_any_instance_of(ContainerRegistry::Client).not_to receive(:delete_repository_tag_by_name)

            is_expected.to include(status: :error)
          end
        end
      end

      context 'and the feature is disabled' do
        before do
          stub_feature_flags(container_registry_fast_tag_delete: false)
        end

        it 'fallbacks to slow delete' do
          expect(service).not_to receive(:fast_delete)
          expect(service).to receive(:slow_delete).with(repository, tags)

          subject
        end
      end
    end

    context 'when the registry does not support fast delete' do
      before do
        stub_tag_digest('latest', 'sha256:configA')
        stub_tag_digest('A', 'sha256:configA')
        stub_tag_digest('Ba', 'sha256:configB')

        allow(repository.client).to receive(:supports_tag_delete?).and_return(false)
      end

      context 'when no params are specified' do
        let_it_be(:params) { {} }

        it 'does not remove anything' do
          expect_any_instance_of(ContainerRegistry::Client).not_to receive(:delete_repository_tag_by_digest)

          is_expected.to include(status: :error)
        end
      end

      context 'with empty tags' do
        let_it_be(:tags) { [] }

        it 'does not remove anything' do
          expect_any_instance_of(ContainerRegistry::Client).not_to receive(:delete_repository_tag_by_digest)

          is_expected.to include(status: :error)
        end
      end

      context 'with tags to delete' do
        let_it_be(:tags) { %w[A Ba] }

        it_behaves_like 'deleting with slow delete container tags', %w[A Ba]

        it 'succeeds when tag delete returns 404' do
          stub_upload("{\n  \"config\": {\n  }\n}", 'sha256:4435000728ee66e6a80e55637fc22725c256b61de344a2ecdeaac6bdb36e8bc3')

          stub_request(:put, "http://registry.gitlab/v2/#{repository.path}/manifests/A")
            .to_return(status: 200, body: "", headers: { 'docker-content-digest' => 'sha256:dummy' })

          stub_request(:put, "http://registry.gitlab/v2/#{repository.path}/manifests/Ba")
            .to_return(status: 200, body: "", headers: { 'docker-content-digest' => 'sha256:dummy' })

          stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/manifests/sha256:dummy")
            .to_return(status: 404, body: "", headers: {})

          is_expected.to include(status: :success)
        end

        context 'with failures' do
          context 'when the dummy manifest generation fails' do
            before do
              stub_upload("{\n  \"config\": {\n  }\n}", 'sha256:4435000728ee66e6a80e55637fc22725c256b61de344a2ecdeaac6bdb36e8bc3', success: false)
            end

            it { is_expected.to include(status: :error) }
          end

          context 'when updating the tags fails' do
            before do
              stub_upload("{\n  \"config\": {\n  }\n}", 'sha256:4435000728ee66e6a80e55637fc22725c256b61de344a2ecdeaac6bdb36e8bc3')

              stub_request(:put, "http://registry.gitlab/v2/#{repository.path}/manifests/A")
                .to_return(status: 500, body: "", headers: { 'docker-content-digest' => 'sha256:dummy' })

              stub_request(:put, "http://registry.gitlab/v2/#{repository.path}/manifests/Ba")
                .to_return(status: 500, body: "", headers: { 'docker-content-digest' => 'sha256:dummy' })

              stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/manifests/sha256:4435000728ee66e6a80e55637fc22725c256b61de344a2ecdeaac6bdb36e8bc3")
                .to_return(status: 200, body: "", headers: {})
            end

            it { is_expected.to include(status: :error) }
          end
        end
      end
    end
  end
end

RSpec.shared_examples 'deleting with fast delete container tags' do |tags|
  it 'deletes the tags by name' do
    tags.each do |tag|
      stub_request(:delete, "http://registry.gitlab/v2/#{repository.path}/tags/reference/#{tag}")
        .to_return(status: 200, body: "")
      expect_delete_tag_by_name(tag)
    end
    is_expected.to include(status: :success)
  end
end

RSpec.shared_examples 'deleting with slow delete container tags' do |tags|
  it 'deletes the tags using a dummy image' do
    stub_upload("{\n  \"config\": {\n  }\n}", 'sha256:4435000728ee66e6a80e55637fc22725c256b61de344a2ecdeaac6bdb36e8bc3')

    tags.each do |tag|
      stub_request(:put, "http://registry.gitlab/v2/#{repository.path}/manifests/#{tag}")
        .to_return(status: 200, body: "", headers: { 'docker-content-digest' => 'sha256:dummy' })
    end

    expect_delete_tag_by_digest('sha256:dummy')

    is_expected.to include(status: :success)
  end
end
