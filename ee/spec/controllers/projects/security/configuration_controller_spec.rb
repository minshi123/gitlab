# frozen_string_literal: true

require 'spec_helper'

describe Projects::Security::ConfigurationController do
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, namespace: group) }

  describe 'GET #show' do
    subject { get :show, params: { namespace_id: project.namespace, project_id: project } }

    it_behaves_like SecurityDashboardsPermissions do
      let(:vulnerable) { project }

      let(:security_dashboard_action) do
        subject
      end
    end

    context 'with user' do
      let(:user) { create(:user) }

      render_views

      before do
        stub_licensed_features(security_dashboard: true)

        group.add_developer(user)
        sign_in(user)
      end

      it "renders data on the project's security configuration" do
        subject

        expect(response).to have_gitlab_http_status(:ok)
        expect(response).to render_template(:show)
        expect(response.body).to have_css(
                                   'div#js-security-configuration'\
          "[data-auto-devops-help-page-path=\"#{help_page_path('topics/autodevops/index')}\"]"\
          "[data-help-page-path=\"#{help_page_path('user/application_security/index')}\"]"\
          "[data-latest-pipeline-path=\"#{help_page_path('ci/pipelines')}\"]"
                                 )
      end

      context 'when the latest pipeline used Auto DevOps' do
        let!(:pipeline) do
          create(
            :ci_pipeline,
            :auto_devops_source,
            project: project,
            ref: project.default_branch,
            sha: project.commit.sha
          )
        end

        it 'reports that Auto DevOps is enabled' do
          subject

          expect(response).to have_gitlab_http_status(:ok)
          expect(response.body).to have_css(
                                     'div#js-security-configuration'\
            '[data-auto-devops-enabled]'\
            "[data-auto-devops-help-page-path=\"#{help_page_path('topics/autodevops/index')}\"]"\
            "[data-help-page-path=\"#{help_page_path('user/application_security/index')}\"]"\
            "[data-latest-pipeline-path=\"#{project_pipeline_path(project, pipeline)}\"]"
                                   )
        end
      end
    end
  end

  describe 'POST #auto_fix' do
    subject { post :auto_fix, params: params }

    let_it_be(:user) { create(:user) }

    # context 'with feature enabled' do
    #
    # end

    context 'with feature disabled' do
      before do
        stub_licensed_features(security_dashboard: true)

        project.add_developer(user)
        sign_in(user)
      end


      let(:params) {}

      it 'returns 404 error' do
        expect(response).to have_gitlab_http_status(:not_found)
      end
    end
  end
end
