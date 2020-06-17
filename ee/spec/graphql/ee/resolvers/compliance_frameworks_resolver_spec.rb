# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::ComplianceFrameworksResolver do
  include GraphqlHelpers

  let(:project) { create(:project) }

  describe '#resolve' do
    context 'when a project has a compliance framework set' do
      before do
        project.update!(compliance_framework_setting: create(:compliance_framework_project_setting, framework: 'sox'))
      end

      subject { resolve_compliance_frameworks(project) }

      it 'includes the name of the compliance frameworks' do
        expect(subject.first.framework).to eq('sox')
      end

      it 'always has exactly one compliance framework' do
        expect(subject.size).to eq(1)
      end

      it 'is associated with the project' do
        expect(subject.first.project).to eq(project)
      end
    end

    context 'when a project has no compliance framework set' do
      subject { resolve_compliance_frameworks(project) }

      it 'is an empty array' do
        expect(subject).to match_array([])
      end
    end
  end

  def resolve_compliance_frameworks(project)
    resolve(described_class, obj: project)
  end
end
