# frozen_string_literal: true
# rubocop:disable Style/Documentation

module Gitlab
  module BackgroundMigration
    module UserMentions
      module Models
        class Snippet < ActiveRecord::Base
          include IsolatedMentionable

          attr_mentionable :title, pipeline: :single_line
          attr_mentionable :description

          self.table_name = 'snippets'

          belongs_to :author, class_name: "User"
          belongs_to :project

          def self.user_mention_model
            Gitlab::BackgroundMigration::UserMentions::Models::SnippetUserMention
          end

          def user_mention_model
            self.class.user_mention_model
          end

          def user_mention_resource_id
            id
          end

          def user_mention_note_id
            'NULL'
          end
        end
      end
    end
  end
end
