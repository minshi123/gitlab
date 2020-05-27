# frozen_string_literal: true

require 'spec_helper'

describe 'Importing Jira Users' do
  include JiraServiceHelper
  include GraphqlHelpers

  let_it_be(:user)    { create(:user) }
  let_it_be(:project) { create(:project) }
  let(:project_path)  { project.full_path }
  let(:start_at)      { 0 }

  let(:mutation) do
    variables = {
      jira_project_key: start_at,
      project_path: project_path
    }

    graphql_mutation(:jira_import_users, variables)
  end

  def mutation_response
    graphql_mutation_response(:jira_import_start)
  end

  def jira_import
    mutation_response['jiraUsers']
  end

  context 'with user without permissions' do
    it_behaves_like 'a mutation that returns top-level errors',
                  errors: [Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR]
  end

    context 'with anonymous user' do
      let(:current_user) { nil }

      it_behaves_like 'Jira import does not start'
      it_behaves_like 'a mutation that returns top-level errors',
                      errors: [Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR]
    end

    context 'with user without permissions' do
      let(:current_user) { user }
      let(:project_path) { project.full_path }

      before do
        project.add_developer(current_user)
      end

      it_behaves_like 'a mutation that returns top-level errors',
                      errors: [Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR]
    end
  end

  context 'when the user has permission' do
    let(:current_user) { user }

    before do
      project.add_maintainer(current_user)
    end

    context 'with project' do
      context 'when the project path is invalid' do
        let(:project_path) { 'foobar' }

        it 'returns an an error' do
          post_graphql_mutation(mutation, current_user: current_user)
          errors = json_response['errors']

          expect(errors.first['message']).to eq(Gitlab::Graphql::Authorize::AuthorizeResource::RESOURCE_ACCESS_ERROR)
        end
      end

      context 'when all params and permissions are ok' do
        context 'when service returns a successful response' do
          it 'returns imported users' do
            post_graphql_mutation(mutation, current_user: current_user)

          end
        end

        context 'when service returns an error response' do
          it 'returns imported users' do
            post_graphql_mutation(mutation, current_user: current_user)
          end
        end
      end
    end
  end
end
