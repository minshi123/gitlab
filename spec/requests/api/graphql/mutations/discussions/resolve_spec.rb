# frozen_string_literal: true

require 'spec_helper'

describe 'Resolving a discussion' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:noteable) { create(:merge_request, source_project: project) }
  let(:discussion) { create(:diff_note_on_merge_request, noteable: noteable, project: project).to_discussion }

  let(:mutation) { graphql_mutation(:discussion_resolve, { id: discussion.to_global_id.to_s }) }
  let(:mutation_response) { graphql_mutation_response(:discussion_resolve) }

  context 'the user is not allowed to create a branch' do
    let_it_be(:current_user) { create(:user) }

    it_behaves_like 'a mutation that returns top-level errors',
      errors: ["The resource that you are attempting to access does not exist or you don't have permission to perform this action"]
  end

  context 'when user has permissions to resolve the discussion' do
    let_it_be(:current_user) { create(:user, developer_projects: [project]) }

    it 'resolves the discussion' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['discussion']).to include(
        'resolved' => true
      )
    end

    context 'when an error is encountered' do
      before do
        allow_next_instance_of(::Discussions::ResolveService) do |service|
          allow(service).to receive(:execute).and_raise(ActiveRecord::RecordNotSaved, 'test error')
        end
      end

      it_behaves_like 'a mutation that returns errors in the response',
        errors: ['test error']
    end
  end
end
