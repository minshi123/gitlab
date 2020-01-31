# frozen_string_literal: true

require 'spec_helper'

describe ChatNotificationService do
  describe 'Associations' do
    before do
      allow(subject).to receive(:activated?).and_return(true)
    end

    it { is_expected.to validate_presence_of :webhook }
  end

  describe '#can_test?' do
    context 'with empty repository' do
      it 'returns true' do
        subject.project = create(:project, :empty_repo)

        expect(subject.can_test?).to be true
      end
    end

    context 'with repository' do
      it 'returns true' do
        subject.project = create(:project, :repository)

        expect(subject.can_test?).to be true
      end
    end
  end

  describe '#execute' do
    subject(:chat_service) { described_class.new }

    let(:user) { create(:user) }
    let(:project) { create(:project, :repository) }
    let(:webhook_url) { 'https://example.gitlab.com/' }
    let(:data) { Gitlab::DataBuilder::Push.build_sample(project, user) }

    before do
      allow(chat_service).to receive_messages(
        project: project,
        project_id: project.id,
        service_hook: true,
        webhook: webhook_url
      )

      WebMock.stub_request(:post, webhook_url)

      subject.active = true
    end

    context 'with a repository' do
      it 'returns true' do
        subject.project = project

        expect(chat_service).to receive(:notify).and_return(true)
        expect(chat_service.execute(data)).to be true
      end
    end

    context 'with an empty repository' do
      let(:data) { Gitlab::DataBuilder::Push.build_sample(subject.project, user) }

      it 'returns true' do
        subject.project = create(:project, :empty_repo)

        expect(chat_service).to receive(:notify).and_return(true)
        expect(chat_service.execute(data)).to be true
      end
    end

    context 'with channel specified' do
      before do
        allow(chat_service).to receive(:push_channel).and_return(channel)
      end

      context 'with single channel name' do
        let(:channel) { 'slack-integration' }

        it 'notifies once' do
          expect(chat_service).to receive(:notify).with(any_args, hash_including(channel: channel)).and_return(true)
          expect(chat_service.execute(data)).to be(true)
        end
      end

      context 'with multiple channel names' do
        let(:channel) { 'slack-integration,slack-test' }

        it 'notifies once' do
          expect(chat_service).to receive(:notify).with(any_args, hash_including(channel: 'slack-integration')).and_return(true)
          expect(chat_service).to receive(:notify).with(any_args, hash_including(channel: 'slack-test')).and_return(true)
          expect(chat_service.execute(data)).to be(true)
        end
      end
    end
  end
end
