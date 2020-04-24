# frozen_string_literal: true

require 'spec_helper'

describe Mutations::Branches::CreateBranch do
  let(:project) { create(:project, :public, :repository) }
  let(:repository) { project.repository }
  let(:user) { create(:user) }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  describe '#resolve' do
    let(:ref) { 'master' }
    let(:branch) { 'new_branch' }
    let(:mutated_branch) { subject[:branch] }

    subject { mutation.resolve(project_path: project.full_path, branch: branch, ref: ref) }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the issue' do
      before do
        project.add_developer(user)
      end

      it 'returns a new branch' do
        expect(mutated_branch).to be_a(OpenStruct)
        expect(mutated_branch.name).to eq('new_branch')
        expect(subject[:errors]).to be_empty
      end

      context 'when passing incorrect ref' do
        let(:ref) { 'unknown' }

        it 'does not create a branch' do
          expect(mutated_branch).to be_nil
        end
      end
    end
  end
end
