# frozen_string_literal: true

require 'spec_helper'

describe Discussions::ResolveService do
  describe '#execute' do
    let_it_be(:project) { create(:project, :repository) }
    let_it_be(:user) { create(:user, developer_projects: [project]) }
    let_it_be(:merge_request) { create(:merge_request, source_project: project) }
    let(:discussion) { create(:diff_note_on_merge_request, noteable: merge_request, project: project).to_discussion }
    let(:params) { {} }
    let(:service) { described_class.new(project, user, params) }

    it "doesn't resolve discussions the user can't resolve" do
      expect(discussion).to receive(:can_resolve?).with(user).and_return(false)

      service.execute(discussion)

      expect(discussion.resolved?).to be(false)
    end

    it 'resolves the discussion' do
      service.execute(discussion)

      expect(discussion.resolved?).to be(true)
    end

    it 'executes the notification service' do
      expect_next_instance_of(MergeRequests::ResolvedDiscussionNotificationService) do |instance|
        expect(instance).to receive(:execute).with(discussion.noteable)
      end

      service.execute(discussion)
    end

    it 'adds a system note to the discussion' do
      issue = create(:issue, project: project)

      expect(SystemNoteService).to receive(:discussion_continued_in_issue).with(discussion, project, user, issue)
      service = described_class.new(project, user, merge_request: merge_request, follow_up_issue: issue)
      service.execute(discussion)
    end

    describe 'resolving multiple discussions at once' do
      it 'can resolve multiple discussions at once' do
        other_discussion = create(:diff_note_on_merge_request, noteable: merge_request, project: project).to_discussion

        service.execute([discussion, other_discussion])

        expect(discussion.resolved?).to be(true)
        expect(other_discussion.resolved?).to be(true)
      end

      it 'raises an argument error if discussions do not belong to the same merge request' do
        other_merge_request = create(:merge_request)
        other_discussion = create(:diff_note_on_merge_request,
                                  noteable: other_merge_request,
                                  project: other_merge_request.source_project
                                  ).to_discussion

        expect { service.execute([discussion, other_discussion]) }.to raise_error(
          ArgumentError,
          'Discussions must be all for the same noteable'
        )
      end
    end

    context 'when discussion is not for a merge request' do
      let_it_be(:design) { create(:design, :with_file, issue: create(:issue, project: project)) }
      let(:discussion) { create(:diff_note_on_design, noteable: design, project: project).to_discussion }

      describe 'merge_request param' do
        context 'when param is missing' do
          it 'does not execute the notification service' do
            expect(MergeRequests::ResolvedDiscussionNotificationService).not_to receive(:new)

            service.execute(discussion)
          end
        end

        context 'when param is present' do
          let(:params) { { merge_request: merge_request } }

          it 'executes the notification service' do
            expect_next_instance_of(MergeRequests::ResolvedDiscussionNotificationService) do |instance|
              expect(instance).to receive(:execute).with(merge_request)
            end

            service.execute(discussion)
          end
        end
      end
    end
  end
end
