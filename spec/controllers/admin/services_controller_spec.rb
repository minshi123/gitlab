# frozen_string_literal: true

require 'spec_helper'

describe Admin::ServicesController do
  let(:admin) { create(:admin) }

  before do
    sign_in(admin)
  end

  describe 'GET #index' do
    it 'creates service templates' do
      expect { get :index }.to change { Service.count }.from(0).to(Service.available_services_names.size)
    end

    it 'avoids N+1 queries' do
      query_count = ActiveRecord::QueryRecorder.new { get :index }.count

      expect(query_count).to eq(7)
    end

    context 'with all existing templates' do
      before do
        Service.create_templates
      end

      it 'does not create service templates' do
        expect { get :index }.to change { Service.count }.by(0)
      end

      it 'avoids N+1 queries' do
        query_count = ActiveRecord::QueryRecorder.new { get :index }.count

        expect(query_count).to eq(6)
      end
    end

    context 'with a few existing templates' do
      before do
        Service.create(template: true, type: 'JiraService')
      end

      it 'creates the rest of the service templates' do
        expect { get :index }.to change { Service.count }.from(1).to(Service.available_services_names.size)
      end

      it 'avoids N+1 queries' do
        query_count = ActiveRecord::QueryRecorder.new { get :index }.count

        expect(query_count).to eq(7)
      end
    end
  end

  describe 'GET #edit' do
    let!(:project) { create(:project) }

    Service.available_services_types.each do |type|
      let!(:service) do
        Service.create(template: true, type: type)
      end

      it 'successfully displays the template' do
        get :edit, params: { id: service.id }

        expect(response).to have_gitlab_http_status(:ok)
      end
    end
  end

  describe "#update" do
    let(:project) { create(:project) }
    let!(:service_template) do
      RedmineService.create(
        project: nil,
        active: false,
        template: true,
        properties: {
          project_url: 'http://abc',
          issues_url: 'http://abc',
          new_issue_url: 'http://abc'
        }
      )
    end

    it 'calls the propagation worker when service is active' do
      expect(PropagateServiceTemplateWorker).to receive(:perform_async).with(service_template.id)

      put :update, params: { id: service_template.id, service: { active: true } }

      expect(response).to have_gitlab_http_status(:found)
    end

    it 'does not call the propagation worker when service is not active' do
      expect(PropagateServiceTemplateWorker).not_to receive(:perform_async)

      put :update, params: { id: service_template.id, service: { properties: {} } }

      expect(response).to have_gitlab_http_status(:found)
    end
  end
end
