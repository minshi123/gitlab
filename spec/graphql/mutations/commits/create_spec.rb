# frozen_string_literal: true

require 'spec_helper'

describe Mutations::Commits::Create do
  subject(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let(:project) { create(:project, :public, :repository) }
  let(:user) { create(:user) }
  let(:context) do
    GraphQL::Query::Context.new(
      query: OpenStruct.new(schema: nil),
      values: { current_user: user },
      object: nil
    )
  end

  describe '#resolve' do
    subject { mutation.resolve(project_path: project.full_path, branch: branch, message: message, actions: actions) }

    let(:branch) { 'master' }
    let(:message) { 'Commit message' }
    let(:actions) do
      [
        {
          action: 'create',
          file_path: 'NEW_FILE.md',
          content: 'Hello'
        }
      ]
    end

    let(:mutated_commit) { subject[:commit] }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can create a commit' do
      before do
        project.add_developer(user)
      end

      context 'when service successfully creates a new commit' do
        it 'returns a new commit' do
          expect(mutated_commit.id).to be
          expect(subject[:errors]).to be_empty
        end
      end
    end
  end
end
