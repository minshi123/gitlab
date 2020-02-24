# frozen_string_literal: true

require 'spec_helper'

describe Projects::DesignManagement::Designs::ResizedImageController do
  include DesignManagementTestHelpers

  let_it_be(:project) { create(:project, :private) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:viewer) { issue.author }
  let_it_be(:size) { :v432x230 }
  let(:design) { create(:design, :with_smaller_image_versions, issue: issue) }
  let(:version) { design.versions.first }

  before do
    enable_design_management
  end

  describe 'GET #show' do
    subject do
      get(:show,
        params: {
          namespace_id: project.namespace,
          project_id: project,
          design_id: design.id,
          sha: version.sha,
          id: size
      })
    end

    before do
      sign_in(viewer)
      subject
    end

    context 'when the user does not have permission' do
      let_it_be(:viewer) { create(:user) }

      specify do
        expect(response).to have_gitlab_http_status(404)
      end
    end

    describe 'Response headers' do
      it 'completes the request successfully' do
        expect(response).to have_gitlab_http_status(200)
      end

      it 'sets Content-Disposition as attachment' do
        filename = design.filename

        expect(response.header['Content-Disposition']).to eq(%Q(attachment; filename=\"#{filename}\"; filename*=UTF-8''#{filename}))
      end

      it 'serves files with Workhorse' do
        expect(response.header[Gitlab::Workhorse::DETECT_HEADER]).to eq 'true'
      end

      it 'sets appropriate caching headers' do
        expect(response.header['Cache-Control']).to eq('private')
        expect(response.header['ETag']).to be_present
      end
    end

    context 'when size is invalid' do
      let(:size) { :foo }

      it 'returns a 404' do
        expect(response).to have_gitlab_http_status(404)
      end
    end

    context 'when design does not have a smaller image size available' do
      let(:design) { create(:design, :with_file, issue: issue) }

      it 'returns a 404' do
        expect(response).to have_gitlab_http_status(404)
      end
    end
  end
end
