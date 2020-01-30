# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20200130161025_migrate_issue_mentions_to_db')

describe MigrateIssueMentionsToDb, :migration, :sidekiq do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:issues) { table(:issues) }

  let(:user) { users.create!(name: 'root', email: 'root@example.com', username: 'root', projects_limit: 0) }
  let(:group) { namespaces.create!(name: 'group1', path: 'group1', owner_id: user.id) }
  let(:project) { projects.create!(name: 'gitlab1', path: 'gitlab1', namespace_id: group.id, visibility_level: 0) }
  let!(:issue1) { issues.create!(title: "title1", title_html: 'title1', description: 'description with @root mention', project_id: project.id, author_id: user.id) }
  let!(:issue2) { issues.create!(title: "title2", title_html: "title2", description: 'description with @group mention', project_id: project.id, author_id: user.id) }
  let!(:issue3) { issues.create!(title: "title3", title_html: "title3", description: 'description with @project mention', project_id: project.id, author_id: user.id) }

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

        expect(migration).to be_scheduled_delayed_migration(2.minutes, 'Issue', join, conditions, false, issue1.id, issue1.id)
        expect(migration).to be_scheduled_delayed_migration(4.minutes, 'Issue', join, conditions, false, issue2.id, issue2.id)
        expect(migration).to be_scheduled_delayed_migration(6.minutes, 'Issue', join, conditions, false, issue3.id, issue3.id)
        expect(BackgroundMigrationWorker.jobs.size).to eq 3
      end
    end
  end
end
