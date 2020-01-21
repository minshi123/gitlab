# frozen_string_literal: true
require 'spec_helper'

describe Notes::QuickActionsService do
  let(:group)   { create(:group) }
  let(:project) { create(:project, group: group) }
  let(:user) { create(:user) }
  let(:issue) { create(:issue, project: project) }
  let(:epic) { create(:epic, group: group)}

  let(:service) { described_class.new(project, user) }

  def execute(note)
    content, update_params = service.execute(note)
    service.apply_updates(update_params, note)

    content
  end

  describe '/epic' do
    let(:note_text) { "/epic #{epic.to_reference(project)}" }
    let(:note) { create(:note_on_issue, noteable: issue, project: project, note: note_text) }

    before do
      group.add_developer(user)
    end

    context 'when epics are not enabled' do
      it 'does not assign the epic' do
        expect(execute(note)).to be_empty
        expect(issue.epic).to be_nil
      end
    end

    context 'when epics are enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'on an issue' do
        it 'assigns the issue to the epic' do
          expect { execute(note) }.to change { issue.reload.epic }.from(nil).to(epic)
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end

        it 'creates a system note' do
          expect { execute(note) }.to change { Note.system.count }.from(0).to(2)
        end
      end

      context 'on a merge request' do
        let(:note_mr) { create(:note_on_merge_request, project: project, note: note_text) }

        it 'leaves the note empty' do
          expect(execute(note_mr)).to be_empty
        end
      end
    end
  end

  describe '/remove_epic' do
    let(:note_text) { "/remove_epic" }
    let(:note) { create(:note_on_issue, noteable: issue, project: project, note: note_text) }

    before do
      issue.update!(epic: epic)
      group.add_developer(user)
    end

    context 'when epics are not enabled' do
      it 'does not remove the epic' do
        expect(execute(note)).to be_empty
        expect(issue.epic).to eq(epic)
      end
    end

    context 'when epics are enabled' do
      before do
        stub_licensed_features(epics: true)
      end

      context 'on an issue' do
        it 'removes the epic' do
          expect { execute(note) }.to change { issue.reload.epic }.from(epic).to(nil)
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end

        it 'creates a system note' do
          expect { execute(note) }.to change { Note.system.count }.from(0).to(2)
        end
      end

      context 'on a merge request' do
        let(:note_mr) { create(:note_on_merge_request, project: project, note: note_text) }

        it 'leaves the note empty' do
          expect(execute(note_mr)).to be_empty
        end
      end
    end
  end

  describe 'Epics' do
    describe '/close' do
      let(:note_text) { "/close" }
      let(:note) { create(:note, noteable: epic, note: note_text) }

      before do
        group.add_developer(user)
      end

      context 'when epics are not enabled' do
        it 'does not close the epic' do
          expect { execute(note) }.not_to change { epic.state }
        end
      end

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'closes the epic' do
          expect { execute(note) }.to change { epic.reload.state }.from('opened').to('closed')
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end
      end
    end

    describe '/reopen' do
      let(:note_text) { "/reopen" }
      let(:note) { create(:note, noteable: epic, note: note_text) }

      before do
        group.add_developer(user)
        epic.update!(state: 'closed')
      end

      context 'when epics are not enabled' do
        it 'does not reopen the epic' do
          expect { execute(note) }.not_to change { epic.state }
        end
      end

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'reopens the epic' do
          expect { execute(note) }.to change { epic.reload.state }.from('closed').to('opened')
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end
      end
    end

    describe '/label' do
      let(:project) { nil }
      let!(:bug) { create(:group_label, title: 'bug', group: group)}
      let!(:project_label) { create(:label, title: 'project_label', project: create(:project, group: group))}
      let(:note_text) { "/label ~bug ~project_label" }
      let(:note) { create(:note, noteable: epic, note: note_text) }

      before do
        group.add_developer(user)
      end

      context 'when epics are not enabled' do
        it 'does not add a label to the epic' do
          expect { execute(note) }.not_to change(epic.labels, :count)
        end
      end

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'adds a group label to the epic' do
          expect { execute(note) }.to change { epic.reload.labels.map(&:title) }.to(['bug'])
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end
      end
    end

    describe '/unlabel' do
      let(:project) { nil }
      let!(:bug) { create(:group_label, title: 'bug', group: group)}
      let!(:feature) { create(:group_label, title: 'feature', group: group)}
      let(:note_text) { "/unlabel ~bug" }
      let(:note) { create(:note, noteable: epic, note: note_text) }

      before do
        group.add_developer(user)
        epic.labels = [bug, feature]
      end

      context 'when epics are not enabled' do
        it 'does not remove any label' do
          expect { execute(note) }.not_to change(epic.labels, :count)
        end
      end

      context 'when epics are enabled' do
        before do
          stub_licensed_features(epics: true)
        end

        it 'removes a requested label from the epic' do
          expect { execute(note) }.to change { epic.reload.labels.map(&:title) }.to(['feature'])
        end

        it 'leaves the note empty' do
          expect(execute(note)).to eq('')
        end
      end
    end
  end

  describe '/assign' do
    let(:project) { create(:project) }
    let(:maintainer) { create(:user) }
    let(:assignee) { create(:user) }
    let(:service) { described_class.new(project, maintainer) }
    let(:note_text) { %(/assign @#{assignee.username} @#{maintainer.username}\n) }

    shared_examples 'assigning a already assigned user' do
      before do
        target.assignees = [assignee]
      end

      it 'adds multiple assignees from the list' do
        _, update_params, message = service.execute(note)

        expect(message).to eq("Assigned @#{maintainer.username}. @#{assignee.username} already assigned.")
        expect { service.apply_updates(update_params, note) }.not_to raise_error
      end
    end

    before do
      project.add_maintainer(maintainer)
      project.add_maintainer(assignee)
    end

    context 'Issue assignees' do
      let(:note) { create(:note_on_issue, note: note_text, project: project) }

      it 'adds multiple assignees from the list' do
        _, update_params, message = service.execute(note)
        service.apply_updates(update_params, note)

        expect(message).to eq("Assigned @#{maintainer.username} and @#{assignee.username}.")
        expect(note.noteable.assignees.count).to eq(2)
      end

      it_behaves_like 'assigning a already assigned user' do
        let(:target) { note.noteable }
      end
    end

    context 'MergeRequest' do
      let(:note) { create(:note_on_merge_request, note: note_text, project: project) }

      it_behaves_like 'assigning a already assigned user' do
        let(:target) { note.noteable }
      end
    end
  end

  describe '/unassign' do
    let(:project) { create(:project) }
    let(:maintainer) { create(:user) }
    let(:assignee) { create(:user) }
    let(:note_text) { %(/unassign @#{maintainer.username}\n) }

    let(:service) { described_class.new(project, maintainer) }

    before do
      project.add_maintainer(maintainer)
    end

    shared_examples 'unassigning a not assigned user' do
      before do
        target.assignees = [assignee]
      end

      it 'adds multiple assignees from the list' do
        _, update_params, message = service.execute(note)

        expect(message).to eq("@#{maintainer.username} already unassigned.")
        expect { service.apply_updates(update_params, note) }.not_to raise_error
      end
    end

    context 'Issue assignees' do
      let(:note) { create(:note_on_issue, note: note_text, project: project) }

      it_behaves_like 'unassigning a not assigned user' do
        let(:target) { note.noteable }
      end
    end

    context 'MergeRequest' do
      let(:note) { create(:note_on_merge_request, note: note_text, project: project) }

      it_behaves_like 'unassigning a not assigned user' do
        let(:target) { note.noteable }
      end
    end
  end

  context '/relate' do
    let(:other_issue) { create(:issue, project: project) }
    let(:note_text) { "/relate #{other_issue.to_reference}" }
    let(:note) { create(:note_on_issue, noteable: issue, project: project, note: note_text) }

    context 'user cannot relate issues' do
      before do
        project.update(visibility: Gitlab::VisibilityLevel::PUBLIC)
      end

      it 'does not create issue relation' do
        expect { execute(note) }.not_to change { IssueLink.count }
      end
    end

    context 'user is allowed to relate issues' do
      before do
        group.add_developer(user)
      end

      context 'related issues are not enabled' do
        before do
          stub_licensed_features(related_issues: false)
        end

        it 'does not create issue relation' do
          expect { execute(note) }.not_to change { IssueLink.count }
        end
      end

      context 'related issues are enabled' do
        before do
          stub_licensed_features(related_issues: true)
        end

        it 'creates issue relation' do
          expect { execute(note) }.to change { IssueLink.count }.by(1)
        end
      end
    end
  end
end
