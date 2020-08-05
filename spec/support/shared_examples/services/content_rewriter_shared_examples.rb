# frozen_string_literal: true

# Expects these to be defined:
# - execute_service
# - new_content - pointer to where to find new content
# - target_project

RSpec.shared_examples 'rewrites content' do
  describe 'rewriting content' do
    before do
      execute_service
    end

    context 'when content is a simple text' do
      let(:original_content) { 'My content' }

      it 'does not rewrite the content' do
        expect(new_content).to eq(original_content)
      end
    end

    context 'when content contains a local reference' do
      let(:local_issue) { create(:issue, project: source_project) }
      let(:original_content) { "See ##{local_issue.iid}" }

      it 'rewrites the local reference correctly' do
        expected_content = "See #{source_project.full_path}##{local_issue.iid}"

        expect(new_content).to eq(expected_content)
      end
    end

    context 'when content contains a cross reference' do
      let(:merge_request) { create(:merge_request) }
      let(:original_content) { "See #{merge_request.project.full_path}!#{merge_request.iid}" }

      it 'rewrites the cross reference correctly' do
        expected_description = "See #{merge_request.project.full_path}!#{merge_request.iid}"

        expect(new_content).to eq(expected_description)
      end
    end

    # context 'when content contains a cross reference within the same namespace' do
    #   let(:second_project) { create(:project, namespace: source_project.group )}
    #   let(:external_issue) { create(:issue, project: second_project) }
    #   let(:original_content) { "See #{external_issue.project.full_path}!#{external_issue.iid}" }

    #   it 'rewrites the cross reference correctly' do
    #     expected_description = "See #{external_issue.project.path}!#{external_issue.iid}"

    #     expect(new_content).to eq(expected_description)
    #   end
    # end

    # context 'when content contains a cross reference to another namespace' do
    #   let(:external_issue) { create(:issue) }
    #   let(:original_content) { "See #{external_issue.project.full_path}##{external_issue.iid}" }

    #   it 'rewrites the cross reference correctly' do
    #     expected_description = "See #{external_issue.project.full_path}##{external_issue.iid}"

    #     expect(new_content).to eq(expected_description)
    #   end
    # end

    context 'when content contains a user reference' do
      let(:user) { create(:user) }
      let(:original_content) { "FYU #{user.to_reference}" }

      it 'works with a user reference' do
        expect(new_content).to eq("FYU #{user.to_reference}")
      end
    end

    context 'when content contains uploads' do
      let(:uploader) { build(:file_uploader, project: source_project) }
      let(:original_content) { "Text and #{uploader.markdown_link}" }

      it 'rewrites uploads in the content' do
        upload = Upload.last

        expect(new_content).not_to eq(original_content)
        expect(new_content).to match(/Text and #{FileUploader::MARKDOWN_PATTERN}/)
        expect(upload.secret).not_to eq(uploader.secret)
        expect(new_content).to include(upload.secret)
        expect(new_content).to include(upload.path)
      end
    end
  end
end
