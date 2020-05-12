# frozen_string_literal: true

require 'spec_helper'

describe Mutations::MergeRequests::Create do
  subject(:mutation) { described_class.new(object: nil, context: context, field: nil) }

  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:user) { create(:user) }
  let_it_be(:context) do
    GraphQL::Query::Context.new(
      query: OpenStruct.new(schema: nil),
      values: { current_user: user },
      object: nil
    )
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        project_path: project.full_path,
        title: title,
        source_branch: source_branch,
        target_branch: target_branch
      )
    end

    let(:title) { 'MergeRequest' }
    let(:source_branch) { 'feature' }
    let(:target_branch) { 'master' }

    let(:mutated_merge_request) { subject[:merge_request] }

    it 'raises an error if the resource is not accessible to the user' do
      expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
    end

    context 'when the user can create a merge request' do
      before do
        project.add_developer(user)
      end

      it 'returns a new merge request' do
        expect(mutated_merge_request.title).to eq(title)
        expect(subject[:errors]).to be_empty
      end

      context 'when target branch does not exist' do
        let(:target_branch) { nil }

        it { expect(mutated_merge_request).to be_nil }
        it { expect(subject[:errors]).to eq(['Target branch can\'t be blank']) }
      end
    end
  end
end
