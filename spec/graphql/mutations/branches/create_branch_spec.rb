# frozen_string_literal: true

require 'spec_helper'

describe Mutations::Branches::CreateBranch do
  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  let(:project) { create(:project, :public, :repository) }
  let(:user) { create(:user) }

  describe '#resolve' do
    subject { mutation.resolve(project_path: project.full_path, branch: branch, ref: ref) }

    let(:branch) { 'new_branch' }
    let(:ref) { 'master' }
    let(:mutated_branch) { subject[:branch] }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can update the issue' do
      before do
        project.add_developer(user)
      end

      it 'returns a new branch' do
        expect(mutated_branch).to be_a(Gitlab::Git::Branch)
        expect(mutated_branch.name).to eq('new_branch')
        expect(subject[:errors]).to be_empty
      end

      context 'when passing incorrect ref' do
        let(:ref) { 'unknown' }

        it 'does not create a branch' do
          expect(mutated_branch).to be_nil
        end

        it 'returns errors' do
          expect(subject[:errors]).to be
        end
      end
    end
  end
end
