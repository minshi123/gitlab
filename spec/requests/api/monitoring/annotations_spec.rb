# frozen_string_literal: true

require 'spec_helper'

describe API::Monitoring::Annotations do
  let_it_be(:user) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:project) { create(:project, :private, :repository, namespace: user.namespace) }
  let_it_be(:environment) { create(:environment, project: project) }
  let(:dashboard) { 'config/prometheus/common_metrics.yml' }
  let(:starting_at) { Time.now.iso8601 }
  let(:ending_at) { 1.hour.from_now.iso8601 }
  let(:description) { 'test description' }
  let(:params) { { dashboard_path: dashboard, starting_at: starting_at, description: description, ending_at: ending_at } }
  let(:result) { JSON.parse(response.body) }

  describe 'POST /environments/:environment_id/metrics_dashboard/annotations' do
    before do
      project.add_developer(user)
      project.add_guest(guest)
    end

    context 'with correct permissions' do
      context 'with valid parameters' do
        it 'creates a new annotation', :aggregate_failures do
          post api("/environments/#{environment.id}/metrics_dashboard/annotations", user), params: params

          expect(response).to have_gitlab_http_status(:created)
          expect(result['id']).to eq(environment.id)
          expect(result['starting_at'].to_time).to eq(starting_at.to_time)
          expect(result['ending_at'].to_time).to eq(ending_at.to_time)
          expect(result['description']).to eq(description)
        end
      end

      context 'with invalid parameters' do
        it 'returns error messsage' do
          post api("/environments/#{environment.id}/metrics_dashboard/annotations", user),
              params: { dashboard_path: nil, starting_at: nil, description: nil }

          expect(response).to have_gitlab_http_status(:bad_request)
          expect(result['message']).to include({ "starting_at" => ["can't be blank"], "description" => ["can't be blank"], "dashboard_path" => ["can't be blank"] })
        end
      end
    end

    context 'without correct permissions' do
      it 'returns error messsage' do
        post api("/environments/#{environment.id}/metrics_dashboard/annotations", guest), params: params

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
