# frozen_string_literal: true

require 'spec_helper'

describe Admin::Geo::SettingsController, :geo do
  include EE::GeoHelpers
  include StubENV

  set(:admin) { create(:admin) }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    sign_in(admin)
  end

  shared_examples 'license required' do
    context 'without a valid license' do
      it 'displays a flash message' do
        get :show
        expect(flash[:tip]).to include('Manage your license')
      end

      it 'does not redirect to the license page' do
        get :show
        expect(response).not_to redirect_to(admin_license_path)
      end
    end
  end

  describe '#show' do
    subject { get :show }

    it_behaves_like 'license required'

    context 'with a valid license' do
      render_views

      before do
        stub_licensed_features(geo: true)
      end

      it 'renders the show template' do
        expect(subject).to have_gitlab_http_status(200)
        expect(subject).to render_template(:show)
      end
    end
  end

  describe '#update' do
    String test_value = '1.0.0.0/0, ::/0'

    context 'with a valid license' do
      before do
        stub_licensed_features(geo: true)
        @request.env['HTTP_REFERER'] = admin_geo_settings_path
        patch :update, params: { application_setting: { geo_node_allowed_ips: test_value } }
      end

      it 'sets the geo node property in ApplicationSetting' do
        expect(ApplicationSetting.current.geo_node_allowed_ips).to eq(test_value)
      end

      it 'redirects the update to the referer' do
        expect(request).to redirect_to(admin_geo_settings_path)
      end
    end
  end
end
