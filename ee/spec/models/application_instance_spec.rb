# frozen_string_literal: true

require 'spec_helper'

describe ApplicationInstance do
  let(:project) { create(:project) }
  let(:pipeline) { create(:ci_pipeline) }

  before do
    pipeline.project = project
    pipeline.save
  end

  subject { described_class.new(project_ids: [project.id]) }

  it_behaves_like Vulnerable do
    let(:vulnerable) { described_class.new(project_ids: [project.id]) }
  end

  describe '#all_pipelines' do
    it 'returns CI pipelines for the given project IDs' do
      expect(subject.all_pipelines).to contain_exactly(pipeline)
    end
  end

  describe '#project_ids_with_security_reports' do
    it 'returns the project IDs it was given' do
      expect(subject.project_ids_with_security_reports).to contain_exactly(project.id)
    end
  end
end
