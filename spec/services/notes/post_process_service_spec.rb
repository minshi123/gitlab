# frozen_string_literal: true

require 'spec_helper'

describe Notes::PostProcessService do
  let(:project) { create(:project) }
  let(:issue) { create(:issue, project: project) }
  let(:user) { create(:user) }

  describe '#execute' do
    before do
      project.add_maintainer(user)
      note_opts = {
        note: 'Awesome comment',
        noteable_type: 'Issue',
        noteable_id: issue.id
      }

      @note = Notes::CreateService.new(project, user, note_opts).execute
    end

    it do
      expect(project).to receive(:execute_hooks)
      expect(project).to receive(:execute_services)

      described_class.new(@note).execute
    end

    context 'with a confidential issue' do
      let(:issue) { create(:issue, :confidential, project: project) }

      it "doesn't call note hooks/services" do
        expect(project).not_to receive(:execute_hooks).with(anything, :note_hooks)
        expect(project).not_to receive(:execute_services).with(anything, :note_hooks)

        described_class.new(@note).execute
      end

      it "calls confidential-note hooks/services" do
        expect(project).to receive(:execute_hooks).with(anything, :confidential_note_hooks)
        expect(project).to receive(:execute_services).with(anything, :confidential_note_hooks)

        described_class.new(@note).execute
      end
    end

    context 'when the noteable is a design' do
      let_it_be(:noteable) { create(:design, :with_file) }
      let_it_be(:discussion_note) { create_note }

      subject { described_class.new(note).execute }

      def create_note(in_reply_to: nil)
        create(:diff_note_on_design, noteable: noteable, in_reply_to: in_reply_to)
      end

      context 'when the note is the start of a new discussion' do
        let(:note) { discussion_note }

        # TODO This test is being temporarily skipped unless run in EE,
        # as we are in the process of moving Design Management to FOSS in 13.0
        # in steps.
        #
        # This spec need two additional MRs to be merged before it can pass:
        #
        # - Routes + controllers, to allow `SystemNotes::DesignManagementService#designs_path`
        #   to build a URI.
        # - Additional models, to allow `SystemNoteMetadata::ICON_TYPES` to include the
        #   names of design icons.
        #
        # See https://gitlab.com/gitlab-org/gitlab/-/issues/212566#note_327724283.
        it 'creates a new system note' do
          skip 'See https://gitlab.com/gitlab-org/gitlab/-/issues/212566#note_327724283' unless Gitlab.ee?

          expect { subject }.to change { Note.system.count }.by(1)
        end
      end

      context 'when the note is a reply within a discussion' do
        let_it_be(:note) { create_note(in_reply_to: discussion_note) }

        it 'does not create a new system note' do
          expect { subject }.not_to change { Note.system.count }
        end
      end
    end
  end
end
