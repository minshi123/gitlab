# frozen_string_literal: true

require 'spec_helper'
require './db/post_migrate/20200127131953_migrate_snippet_mentions_to_db'
require './db/post_migrate/20200127151953_migrate_snippet_notes_mentions_to_db'

describe Gitlab::BackgroundMigration::UserMentions::CreateResourceUserMention do
  include MigrationsHelpers

  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:notes) { table(:notes) }

  let(:author) { users.create!(email: 'author@example.com', notification_email: 'author@example.com', name: 'author', username: 'author', projects_limit: 10, state: 'active') }
  let(:member) { users.create!(email: 'member@example.com', notification_email: 'member@example.com', name: 'member', username: 'member', projects_limit: 10, state: 'active') }
  let(:admin) { users.create!(email: 'administrator@example.com', notification_email: 'administrator@example.com', name: 'administrator', username: 'administrator', admin: 1, projects_limit: 10, state: 'active') }
  let(:john_doe) { users.create!(email: 'john_doe@example.com', notification_email: 'john_doe@example.com', name: 'john_doe', username: 'john_doe', projects_limit: 10, state: 'active') }
  let(:skipped) { users.create!(email: 'skipped@example.com', notification_email: 'skipped@example.com', name: 'skipped', username: 'skipped', projects_limit: 10, state: 'active') }

  let(:mentioned_users) { [author, member, admin, john_doe, skipped] }
  let(:user_mentions) { mentioned_users.map { |u| "@#{u.username}" }.join(' ') }

  let(:group) { namespaces.create!(name: 'test1', path: 'test1', runners_token: 'my-token1', project_creation_level: 1, visibility_level: 20, type: 'Group') }
  let(:inaccessible_group) { namespaces.create!(name: 'test2', path: 'test2', runners_token: 'my-token2', project_creation_level: 1, visibility_level: 0, type: 'Group') }

  let(:mentioned_groups) { [group, inaccessible_group] }
  let(:group_mentions) { [group, inaccessible_group].map { |gr| "@#{gr.path}" }.join(' ') }
  let(:description_mentions) { "description with mentions #{user_mentions} and #{group_mentions}" }

  before do
    # build personal namespaces and routes for users
    mentioned_users.each { |u| u.becomes(User).save! }

    # build namespaces and routes for groups
    mentioned_groups.each do |gr|
      gr.name += '-org'
      gr.path += '-org'
      gr.becomes(Namespace).save!
    end
  end

  context 'migrate snippet mentions' do
    let(:projects) { table(:projects) }
    let(:snippets) { table(:snippets) }
    let(:snippet_user_mentions) { table(:snippet_user_mentions) }

    let(:project) { projects.create!(id: 1, name: 'gitlab1', path: 'gitlab1', namespace_id: group.id, visibility_level: 0) }
    let(:snippet) { snippets.create!(project_id: project.id, author_id: author.id, description: description_mentions) }
    let(:snippet_without_mentions) { snippets.create!(project_id: project.id, author_id: author.id, description: 'some description') }

    it 'migrates mentions' do
      join = MigrateSnippetMentionsToDb::JOIN
      conditions = MigrateSnippetMentionsToDb::QUERY_CONDITIONS

      expect do
        subject.perform('Snippet', join, conditions, false, snippet.id, snippet.id)
      end.to change { snippet_user_mentions.count }.by(1)

      snippet_user_mention = snippet_user_mentions.last
      expect(snippet_user_mention.mentioned_users_ids.sort).to eq(users.pluck(:id).sort)
      expect(snippet_user_mention.mentioned_groups_ids.sort).to eq([group.id])
      expect(snippet_user_mention.mentioned_groups_ids.sort).not_to include(inaccessible_group.id)
    end

    context 'mentions in note' do
      let(:snippet_note) { notes.create!(noteable_id: snippet.id, noteable_type: 'Snippet', project_id: project.id, author_id: author.id, note: description_mentions) }
      let(:snippet_note2) { notes.create!(noteable_id: snippet.id, noteable_type: 'Snippet', project_id: project.id, author_id: author.id, note: 'sample note') }
      let(:system_snippet_note) { notes.create!(noteable_id: snippet.id, noteable_type: 'Snippet', project_id: project.id, author_id: author.id, note: description_mentions, system: true) }

      before do
        snippet_note.becomes(Note).save!
        snippet_note2.becomes(Note).save!
        system_snippet_note.becomes(Note).save!
      end

      it 'migrates mentions from note' do
        join = MigrateSnippetNotesMentionsToDb::JOIN
        conditions = MigrateSnippetNotesMentionsToDb::QUERY_CONDITIONS

        expect do
          subject.perform('Snippet', join, conditions, true, Note.minimum(:id), Note.maximum(:id))
        end.to change { snippet_user_mentions.where(snippet_id: snippet.id).count }.by(2)

        epic_user_mention = snippet_user_mentions.last
        expect(epic_user_mention.mentioned_users_ids.sort).to eq(users.pluck(:id).sort)
        expect(epic_user_mention.mentioned_groups_ids.sort).to eq([group.id])
        expect(epic_user_mention.mentioned_groups_ids.sort).not_to include(inaccessible_group.id)
      end
    end
  end
end
