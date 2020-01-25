# frozen_string_literal: true

require 'spec_helper'

describe Security::VulnerableProjectsFinder do
  describe '#execute' do
    let(:group) { create(:group) }
    let(:projects) { Project.all }
    let(:safe_project) { create(:project, namespace: group) }
    let(:vulnerable_project) { create(:project, namespace: group) }
    let(:vulnerability) { create(:vulnerabilities_occurrence, report_type: :dast) }

    before do
      vulnerability.update(project: vulnerable_project)
    end

    subject { described_class.new(projects).execute }

    it 'returns the projects that have vulnerabilities from the collection of projects given to it' do
      expect(subject.count).to be(1)
      expect(subject.first).to eq(vulnerable_project)
    end

    it 'does not include projects that only have dismissed vulnerabilities' do
      create(
        :vulnerability_feedback,
        category: :dast,
        feedback_type: :dismissal,
        project: vulnerable_project,
        project_fingerprint: vulnerability.project_fingerprint
      )

      expect(subject).to be_empty
    end

    it 'only uses 1 query' do
      another_project = create(:project, namespace: group)
      dismissed_vulnerability = create(:vulnerabilities_occurrence, project: another_project)
      create(
        :vulnerability_feedback,
        project_fingerprint: dismissed_vulnerability.project_fingerprint,
        feedback_type: :dismissal
      )

      expect { subject }.not_to exceed_query_limit(1)
    end
  end
end
