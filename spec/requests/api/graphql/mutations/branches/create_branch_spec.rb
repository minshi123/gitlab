# frozen_string_literal: true

require 'spec_helper'

describe 'Creation of a new branch' do
  include GraphqlHelpers

  let(:current_user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:ref) { 'master' }
  let(:input) { { ref: ref } }

  let(:mutation) do
    variables = {
      project_path: project.full_path,
      branch: 'new_branch'
    }
    graphql_mutation(:create_branch, variables.merge(input))
  end
  let(:mutation_response) { graphql_mutation_response(:create_branch) }

  before do
    project.add_developer(current_user)
  end

  context 'the user is not allowed to create a branch' do
    let(:current_user) { create(:user) }

    it 'returns an error' do
      error = "The resource that you are attempting to access does not exist or you don't have permission to perform this action"
      post_graphql_mutation(mutation, current_user: current_user)

      expect(graphql_errors).to include(a_hash_including('message' => error))
    end
  end

  it 'creates a new branch' do
    post_graphql_mutation(mutation, current_user: current_user)

    binding.pry
    expect(response).to have_gitlab_http_status(:success)
    expect(mutation_response['branch']).to include(
      'name' => 'new_branch'
    )
  end

  context 'when ref is not correct' do
    let(:ref) { 'unknown' }

    it 'returns internal server error' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(graphql_errors).to eq('')
    end
  end
end
