# frozen_string_literal: true

module Gitlab
  module JiraImport
    class IssueSerializer
      attr_reader :jira_issue, :project, :params, :formatter

      def initialize(project, jira_issue, params = {})
        @jira_issue = jira_issue
        @project = project
        @params = params
        @formatter = Gitlab::ImportFormatter.new
      end

      def execute
        {
          iid: params[:iid],
          project_id: project.id,
          description: description,
          title: title,
          state_id: map_status(jira_issue.status.statusCategory),
          updated_at: jira_issue.updated,
          created_at: jira_issue.created,
          author_id: project.creator_id # TODO: map actual author: https://gitlab.com/gitlab-org/gitlab/-/issues/210580
        }
      end

      private

      def title
        "[#{jira_issue.key}] #{jira_issue.summary}"
      end

      def description
        body = []
        body << formatter.author_line(jira_issue.reporter.displayName)
        body << formatter.assignee_line(jira_issue.assignee.displayName) if jira_issue.assignee
        body << jira_issue.description
        body << metadata

        body.join
      end

      def map_status(jira_status_category)
        case jira_status_category["key"].downcase
        when 'done'
          Issuable::STATE_ID_MAP[:closed]
        else
          Issuable::STATE_ID_MAP[:opened]
        end
      end

      def metadata
        @metadata = []

        add_field_name_value('issuetype', 'Issue type')
        add_field_name_value('priority', 'Priority')
        add_labels_value
        add_simple_field_value('environment', 'Environment')
        add_simple_field_value('duedate', 'Due date')
        add_parent_value
        add_versions_value

        return if @metadata.blank?

        @metadata.prepend("\n\n---\n\n*Issue metadata*\n\n")
      end

      def add_simple_field_value(field_key, label)
        return if fields[field_key].blank?

        @metadata << "- #{label}: #{fields[field_key]}\n"
      end

      def add_field_name_value(field_key, label)
        return if fields[field_key].blank?

        @metadata << "- #{label}: #{fields[field_key]['name']}\n"
      end

      def add_labels_value
        return if fields['labels'].blank?

        @metadata << "- Labels: #{fields['labels'].join(', ')}\n"
      end

      def add_parent_value
        return if fields['parent'].blank?

        @metadata << "- Parent issue: #{fields['parent']['key']}: #{fields['parent']['fields']['summary']}\n"
      end

      def add_versions_value
        return if fields['fixVersions'].blank?

        @metadata << "- Fix versions: #{fields['fixVersions'].map { |version| version['name'] }.join(', ') }"
      end

      def fields
        jira_issue.fields
      end
    end
  end
end
