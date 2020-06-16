# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::Project do
  let(:project) { create(:project) }

  let(:entity) do
    ::API::Entities::Project.new(project)
  end

  subject { entity.as_json }

  context 'compliance_frameworks' do
    context 'when compliance_framework feature is enabled' do
      before do
        stub_licensed_features(compliance_framework: true)
      end

      it 'is an array containing a single compliance framework' do
        project.update!(compliance_framework_setting: create(:compliance_framework_project_setting, :sox))

        expect(subject[:compliance_frameworks]).to contain_exactly('sox')
      end

      it 'is empty array when project has no compliance framework' do
        expect(subject[:compliance_frameworks]).to match_array([])
      end
    end

    context 'when compliance_framework feature is disabled' do
      before do
        stub_licensed_features(compliance_framework: false)
      end

      it 'is nil' do
        expect(subject[:compliance_frameworks]).to be_nil
      end
    end
  end
end
