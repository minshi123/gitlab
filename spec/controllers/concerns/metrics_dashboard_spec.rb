# frozen_string_literal: true

require 'spec_helper'

describe MetricsDashboard do
  include MetricsDashboardHelpers

  describe 'GET #metrics_dashboard' do
    let_it_be(:user) { create(:user) }
    let_it_be(:project) { project_with_dashboard('.gitlab/dashboards/test.yml') }
    let_it_be(:environment) { create(:environment, project: project) }

    before do
      sign_in(user)
      project.add_maintainer(user)
    end

    controller(::ApplicationController) do
      include MetricsDashboard # rubocop:disable RSpec/DescribedClass
    end

    let(:json_response) do
      routes.draw { get "metrics_dashboard" => "anonymous#metrics_dashboard" }
      response = get :metrics_dashboard, format: :json

      JSON.parse(response.parsed_body)
    end

    context 'when no parameters are provided' do
      it 'returns an error json_response' do
        expect(json_response['status']).to eq('error')
      end
    end

    context 'when params are provided' do
      let(:params) { { environment: environment } }

      before do
        allow(controller).to receive(:project).and_return(project)
        allow(controller)
          .to receive(:metrics_dashboard_params)
          .and_return(params)
      end

      it 'returns the specified dashboard' do
        expect(json_response['dashboard']['dashboard']).to eq('Environment metrics')
        expect(json_response).not_to have_key('all_dashboards')
      end

      context 'when the params are in an alternate format' do
        let(:params) { ActionController::Parameters.new({ environment: environment }).permit! }

        it 'returns the specified dashboard' do
          expect(json_response['dashboard']['dashboard']).to eq('Environment metrics')
          expect(json_response).not_to have_key('all_dashboards')
        end
      end

      context 'when parameters are provided and the list of all dashboards is required' do
        before do
          allow(controller).to receive(:include_all_dashboards?).and_return(true)
        end

        it 'returns a dashboard in addition to the list of dashboards' do
          expect(json_response['dashboard']['dashboard']).to eq('Environment metrics')
          expect(json_response).to have_key('all_dashboards')
        end

        context 'in all_dashboard list' do
          let(:system_dashboard) { json_response['all_dashboards'][0] }
          let(:project_dashboard) { json_response['all_dashboards'][1] }

          it 'includes project_blob_path only for project dashboards' do
            expect(system_dashboard['project_blob_path']).to be_nil
            expect(project_dashboard['project_blob_path']).to eq("/#{project.namespace.path}/#{project.name}/blob/master/.gitlab/dashboards/test.yml")
          end

          context 'when a user can collaborate on project' do
            it 'sets can_edit to true for project dashboards' do
              expect(system_dashboard['can_edit']).to eq(false)
              expect(project_dashboard['can_edit']).to eq(true)
            end
          end

          context 'when user does not have permissions to edit project dashboard' do
            before do
              allow(controller).to receive(:can_collaborate_with_project?).and_return(false)
            end

            it 'sets can_edit to false for project dashboards' do
              expect(system_dashboard['can_edit']).to eq(false)
              expect(project_dashboard['can_edit']).to eq(false)
            end
          end
        end
      end
    end
  end
end
