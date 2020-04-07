# frozen_string_literal: true

require 'spec_helper'

describe Gitlab::StaticSiteEditor::Config do
  subject(:config) { described_class.new(repository, ref, file_path, return_url) }

  let(:project) { create(:project, :public, :repository, name: 'project', namespace: namespace) }
  let(:namespace) { create(:namespace, name: 'namespace') }
  let(:repository) { project.repository }
  let(:ref) { 'master' }
  let(:file_path) { 'README.md' }
  let(:return_url) { 'http://example.com' }

  describe '#repository' do
    subject { config.repository }
    it { is_expected.to eq(repository) }
  end

  describe '#ref' do
    subject { config.ref }
    it { is_expected.to eq(ref) }
  end

  describe '#file_path' do
    subject { config.file_path }
    it { is_expected.to eq(file_path) }
  end

  describe '#return_url' do
    subject { config.return_url }
    it { is_expected.to eq(return_url) }
  end

  describe '#project' do
    subject { config.project }
    it { is_expected.to eq(project) }
  end

  describe '#commit' do
    subject { config.commit }

    it { is_expected.to be_a(::Commit) }
  end

  describe '#payload' do
    subject { config.payload }

    it 'returns data for the frontend component' do
      is_expected.to include(
        branch: 'master',
        commit: a_kind_of(String),
        namespace: 'namespace',
        path: 'README.md',
        project: 'project',
        project_id: project.id,
        return_url: 'http://example.com'
      )
    end
  end
end
