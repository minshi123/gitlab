# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Issues::Update do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:project_label) { create(:label, project: project) }
  let(:issue) { create(:issue, project: project, labels: [project_label]) }

  let(:expected_attributes) do
    {
      title: 'new title',
      description: 'new description',
      confidential: true,
      due_date: Date.tomorrow
    }
  end
  let(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }
  let(:mutated_issue) { subject[:issue] }

  specify { expect(described_class).to require_graphql_authorizations(:update_issue) }

  describe '#resolve' do
    let(:mutation_params) do
      {
        project_path: project.full_path,
        iid: issue.iid
      }.merge(expected_attributes)
    end

    subject { mutation.resolve(mutation_params) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the issue' do
      before do
        project.add_developer(user)
      end

      it 'updates issue with correct values' do
        subject

        expect(issue.reload).to have_attributes(expected_attributes)
      end

      context 'when iid does not exist' do
        it 'raises resource not available error' do
          mutation_params[:iid] = non_existing_record_iid

          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when changing labels' do
        let(:label_1) { create(:label, project: project) }
        let(:label_2) { create(:label, project: project) }

        it 'adds and removes labels correctly' do
          mutation_params[:add_label_ids] = [label_1.id, label_2.id]
          mutation_params[:remove_label_ids] = [project_label.id]

          subject

          expect(issue.reload.labels).to match_array([label_1, label_2])
        end
      end
    end
  end
end
