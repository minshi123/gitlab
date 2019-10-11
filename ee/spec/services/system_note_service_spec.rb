# frozen_string_literal: true

require 'spec_helper'

describe SystemNoteService do
  include ProjectForksHelper
  include Gitlab::Routing
  include RepoHelpers
  include DesignManagementTestHelpers

  let_it_be(:group)    { create(:group) }
  let_it_be(:project)  { create(:project, :repository, group: group) }
  let_it_be(:author)   { create(:user) }
  let_it_be(:noteable) { create(:issue, project: project) }
  let_it_be(:issue)    { noteable }
  let_it_be(:epic)     { create(:epic, group: group) }

  describe '.relate_issue' do
    let(:noteable_ref) { double }
    let(:noteable) { double }

    before do
      allow(noteable).to receive(:project).and_return(double)
    end

    it 'calls IssuableService' do
      expect_next_instance_of(::SystemNotes::IssuablesService) do |service|
        expect(service).to receive(:relate_issue).with(noteable_ref)
      end

      described_class.relate_issue(noteable, noteable_ref, double)
    end
  end

  describe '.unrelate_issue' do
    let(:noteable_ref) { double }
    let(:noteable) { double }

    before do
      allow(noteable).to receive(:project).and_return(double)
    end

    it 'calls IssuableService' do
      expect_next_instance_of(::SystemNotes::IssuablesService) do |service|
        expect(service).to receive(:unrelate_issue).with(noteable_ref)
      end

      described_class.unrelate_issue(noteable, noteable_ref, double)
    end
  end

  describe '.design_version_added' do
    let(:version) { create(:design_version) }

    it 'calls DesignManagementService' do
      expect_next_instance_of(EE::SystemNotes::DesignManagementService) do |service|
        expect(service).to receive(:design_version_added).with(version)
      end

      described_class.design_version_added(version)
    end
  end

  describe '.design_discussion_added' do
    let(:discussion_note) { create(:diff_note_on_design) }

    it 'calls DesignManagementService' do
      expect_next_instance_of(EE::SystemNotes::DesignManagementService) do |service|
        expect(service).to receive(:design_discussion_added).with(discussion_note)
      end

      described_class.design_discussion_added(discussion_note)
    end
  end

  describe '.approve_mr' do
    it 'calls MergeRequestsService' do
      expect_next_instance_of(::SystemNotes::MergeRequestsService) do |service|
        expect(service).to receive(:approve_mr)
      end

      described_class.approve_mr(noteable, author)
    end
  end

  describe '.unapprove_mr' do
    it 'calls MergeRequestsService' do
      expect_next_instance_of(::SystemNotes::MergeRequestsService) do |service|
        expect(service).to receive(:unapprove_mr)
      end

      described_class.unapprove_mr(noteable, author)
    end
  end

  describe '.change_weight_note' do
    it 'calls IssuableService' do
      expect_next_instance_of(::SystemNotes::IssuablesService) do |service|
        expect(service).to receive(:change_weight_note)
      end

      described_class.change_weight_note(noteable, project, author)
    end
  end

  describe '.change_epic_date_note' do
    let(:date_type) { double }
    let(:date) { double }

    it 'calls EpicsService' do
      expect_next_instance_of(EE::SystemNotes::EpicsService) do |service|
        expect(service).to receive(:change_epic_date_note).with(date_type, date)
      end

      described_class.change_epic_date_note(noteable, author, date_type, date)
    end
  end

  describe '.epic_issue' do
    let(:type) { double }

    it 'calls EpicsService' do
      expect_next_instance_of(EE::SystemNotes::EpicsService) do |service|
        expect(service).to receive(:epic_issue).with(noteable, type)
      end

      described_class.epic_issue(epic, noteable, author, type)
    end
  end

  describe '.issue_on_epic' do
    let(:type) { double }

    it 'calls EpicsService' do
      expect_next_instance_of(EE::SystemNotes::EpicsService) do |service|
        expect(service).to receive(:issue_on_epic).with(noteable, type)
      end

      described_class.issue_on_epic(noteable, epic, author, type)
    end
  end

  describe '.change_epics_relation' do
    let(:child_epic) { double }
    let(:type) { double }

    it 'calls EpicsService' do
      expect_next_instance_of(EE::SystemNotes::EpicsService) do |service|
        expect(service).to receive(:change_epics_relation).with(child_epic, type)
      end

      described_class.change_epics_relation(epic, child_epic, author, type)
    end
  end

  describe '.merge_train' do
    subject { described_class.merge_train(noteable, project, author, noteable.merge_train) }

    let(:noteable) { create(:merge_request, :on_train, source_project: project, target_project: project) }

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'merge train' system note" do
      expect(subject.note).to eq('started a merge train')
    end

    context 'when index of the merge request is not zero' do
      before do
        allow(noteable.merge_train).to receive(:index) { 1 }
      end

      it "posts the 'merge train' system note" do
        expect(subject.note).to eq('added this merge request to the merge train at position 2')
      end
    end
  end

  describe '.cancel_merge_train' do
    subject { described_class.cancel_merge_train(noteable, project, author) }

    let(:noteable) { create(:merge_request, :on_train, source_project: project, target_project: project) }
    let(:reason) { }

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'merge train' system note" do
      expect(subject.note).to eq('removed this merge request from the merge train')
    end
  end

  describe '.abort_merge_train' do
    subject { described_class.abort_merge_train(noteable, project, author, 'source branch was updated') }

    let(:noteable) { create(:merge_request, :on_train, source_project: project, target_project: project) }
    let(:reason) { }

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'merge train' system note" do
      expect(subject.note).to eq('removed this merge request from the merge train because source branch was updated')
    end
  end

  describe '.add_to_merge_train_when_pipeline_succeeds' do
    subject { described_class.add_to_merge_train_when_pipeline_succeeds(noteable, project, author, pipeline.sha) }

    let(:pipeline) { build(:ci_pipeline) }

    let(:noteable) do
      create(:merge_request, source_project: project, target_project: project)
    end

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'add to merge train when pipeline succeeds' system note" do
      expect(subject.note).to match(%r{enabled automatic add to merge train when the pipeline for (\w+/\w+@)?\h{40} succeeds})
    end
  end

  describe '.cancel_add_to_merge_train_when_pipeline_succeeds' do
    subject { described_class.cancel_add_to_merge_train_when_pipeline_succeeds(noteable, project, author) }

    let(:noteable) do
      create(:merge_request, source_project: project, target_project: project)
    end

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'add to merge train when pipeline succeeds' system note" do
      expect(subject.note).to eq 'cancelled automatic add to merge train'
    end
  end

  describe '.abort_add_to_merge_train_when_pipeline_succeeds' do
    subject { described_class.abort_add_to_merge_train_when_pipeline_succeeds(noteable, project, author, 'target branch was changed') }

    let(:noteable) do
      create(:merge_request, source_project: project, target_project: project)
    end

    it_behaves_like 'a system note' do
      let(:action) { 'merge' }
    end

    it "posts the 'add to merge train when pipeline succeeds' system note" do
      expect(subject.note).to eq 'aborted automatic add to merge train because target branch was changed'
    end
  end
end
