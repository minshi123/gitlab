# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Ci::Build::Releaser do
  subject { described_class.new(config: config[:release_job][:release]).script }

  describe '#script' do
    context 'all nodes' do
      let(:config) do
        {
          release_job: {
            stage: 'release',
            only: 'tags',
            script: ['make changelog | tee release_changelog.txt'],
            release: {
              name: 'Release $CI_COMMIT_SHA',
              description: 'Created using the release-cli $EXTRA_DESCRIPTION',
              tag_name: 'release-$CI_COMMIT_SHA',
              ref: '$CI_COMMIT_SHA'
            }
          }
        }
      end

      it 'generates the script' do
        expect(subject).to eq('release-cli create --name "Release $CI_COMMIT_SHA" --description "Created using the release-cli $EXTRA_DESCRIPTION" --tag-name "release-$CI_COMMIT_SHA" --ref "$CI_COMMIT_SHA"')
      end
    end

    context '`name` only' do
      let(:config) do
        {
          release_job: {
            stage: 'release',
            only: 'tags',
            release: {
              name: 'Release $CI_COMMIT_SHA'
            }
          }
        }
      end

      it 'generates the script' do
        expect(subject).to eq('release-cli create --name "Release $CI_COMMIT_SHA"')
      end
    end

    context '`description` only' do
      let(:config) do
        {
          release_job: {
            stage: 'release',
            only: 'tags',
            release: {
              description: 'Created using the release-cli $EXTRA_DESCRIPTION'
            }
          }
        }
      end

      it 'generates the script' do
        expect(subject).to eq('release-cli create --description "Created using the release-cli $EXTRA_DESCRIPTION"')
      end
    end

    context '`tag_name` only' do
      let(:config) do
        {
          release_job: {
            stage: 'release',
            only: 'tags',
            release: {
              tag_name: 'release-$CI_COMMIT_SHA'
            }
          }
        }
      end

      it 'generates the script' do
        expect(subject).to eq('release-cli create --tag-name "release-$CI_COMMIT_SHA"')
      end
    end

    context '`ref` only' do
      let(:config) do
        {
          release_job: {
            stage: 'release',
            only: 'tags',
            release: {
              ref: '$CI_COMMIT_SHA'
            }
          }
        }
      end

      it 'generates the script' do
        expect(subject).to eq('release-cli create --ref "$CI_COMMIT_SHA"')
      end
    end
  end
end
