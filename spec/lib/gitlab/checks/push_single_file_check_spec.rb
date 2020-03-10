# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::Checks::PushSingleFileCheck do
  let(:snippet) { create(:snippet, :repository) }
  let(:changes) { { oldrev: oldrev, newrev: newrev, ref: ref } }
  let(:timeout) { Gitlab::GitAccess::INTERNAL_TIMEOUT }
  let(:logger) { Gitlab::Checks::TimedLogger.new(timeout: timeout) }

  subject { described_class.new(changes, repository: snippet.repository, logger: logger) }

  describe '#validate!' do
    using RSpec::Parameterized::TableSyntax

    before do
      allow(snippet.repository).to receive(:new_commits).and_return(
        snippet.repository.commits_between(oldrev, newrev)
      )
    end

    context 'initial creation' do
      let(:oldrev) { '4b825dc642cb6eb9a060e54bf8d69288fbee4904' }
      let(:newrev) { TestEnv::BRANCH_SHA["snippet/single-file"] }
      let(:ref) { "refs/heads/snippet/single-file" }

      it 'allows creation' do
        expect { subject.validate! }.not_to raise_error
      end
    end

    where(:old, :new, :valid) do
      'single-file' | 'edit-file'            | true
      'single-file' | 'multiple-files'       | false
      'single-file' | 'no-files'             | false
      'edit-file'   | 'rename-and-edit-file' | true
    end

    with_them do
      let(:oldrev) { TestEnv::BRANCH_SHA["snippet/#{old}"] }
      let(:newrev) { TestEnv::BRANCH_SHA["snippet/#{new}"] }
      let(:ref) { "refs/heads/snippet/#{new}" }

      it "verifies" do
        if valid
          expect { subject.validate! }.not_to raise_error
        else
          expect { subject.validate! }.to raise_error(Gitlab::GitAccess::ForbiddenError)
        end
      end
    end
  end
end
