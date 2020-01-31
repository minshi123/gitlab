# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200131125025_migrate_issue_notes_mentions_to_db')

describe MigrateIssueNotesMentionsToDb, :migration, :sidekiq do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:issues) { table(:issues) }
  let(:notes) { table(:notes) }

  let(:user) { users.create!(name: 'root', email: 'root@example.com', username: 'root', projects_limit: 0) }
  let(:group) { namespaces.create!(name: 'group1', path: 'group1', owner_id: user.id) }
  let(:project) { projects.create!(name: 'gitlab1', path: 'gitlab1', namespace_id: group.id, visibility_level: 0) }
  let!(:issue) { issues.create!(title: "title1", title_html: 'title1', description: 'description with @root mention', project_id: project.id, author_id: user.id) }
  let!(:note1) { notes.create!(note: 'note1 for @root to check', noteable_id: issue.id, noteable_type: 'Issue') }
  let!(:note2) { notes.create!(note: 'note2 for @root to check', noteable_id: issue.id, noteable_type: 'Issue', system: true) }
  let!(:note3) { notes.create!(note: 'note3 for @root to check', noteable_id: issue.id, noteable_type: 'Issue') }

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)
  end

  it 'schedules epic mentions migrations' do
    Sidekiq::Testing.fake! do
      Timecop.freeze do
        migrate!

        migration = described_class::MIGRATION
        join = described_class::JOIN
        conditions = described_class::QUERY_CONDITIONS

        expect(migration).to be_scheduled_delayed_migration(2.minutes, 'Issue', join, conditions, true, note1.id, note1.id)
        expect(migration).to be_scheduled_delayed_migration(4.minutes, 'Issue', join, conditions, true, note2.id, note2.id)
        expect(migration).to be_scheduled_delayed_migration(6.minutes, 'Issue', join, conditions, true, note3.id, note3.id)
        expect(BackgroundMigrationWorker.jobs.size).to eq 3
      end
    end
  end
end
