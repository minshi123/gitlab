# frozen_string_literal: true

require 'spec_helper'

describe API::Monitoring::Annotations do
  let_it_be(:user) { create(:user) }
  let_it_be(:guest) { create(:user) }
  let_it_be(:project) { create(:project, :private, :repository, namespace: user.namespace) }
  let_it_be(:environment) { create(:environment, project: project) }
  let(:dashboard) { 'config/prometheus/common_metrics.yml' }

  describe 'POST /environments/:environment_id/metrics_dashboard/annotations' do
    before do
      project.add_developer(user)
      project.add_guest(guest)
    end

    context 'with correct permissions' do
      context 'when create is successful' do
        it 'creates a new annotation', :aggregate_failures do
          from = Time.now.iso8601
          description = 'test description'
          post api("/environments/#{environment.id}/metrics_dashboard/annotations", user),
            params: { dashboard_path: dashboard, starting_at: from, description: description }

          expect(response).to have_gitlab_http_status(:created)

          result = JSON.parse(response.body)
          expect(result['id']).to eq(environment.id)
          expect(result['starting_at'].to_time).to eq(from.to_time)
          expect(result['description']).to eq(description)
        end
      end

      context 'when create is not successful' do
        it 'does not work' do
          allow_next_instance_of(Metrics::Dashboard::Annotations::CreateService) do |annotation|
            allow(annotation).to receive(:execute).and_return({ status: :error })
          end

          from = Time.now.iso8601
          description = 'test description'

          post api("/environments/#{environment.id}/metrics_dashboard/annotations", user),
              params: { dashboard_path: dashboard, starting_at: from, description: description }

          expect(response).to have_gitlab_http_status(:created)
        end
      end
    end

    context 'without correct permissions' do
      it 'creates a new annotation', :aggregate_failures do
        from = Time.now.iso8601
        description = 'test description'
        post api("/environments/#{environment.id}/metrics_dashboard/annotations", guest),
          params: { dashboard_path: dashboard, starting_at: from, description: description }

        expect(response).to have_gitlab_http_status(:forbidden)
      end
    end
  end
end
