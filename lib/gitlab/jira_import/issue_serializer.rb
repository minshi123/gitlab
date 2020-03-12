# frozen_string_literal: true

module Gitlab
  module JiraImport
    class IssueSerializer
      attr_reader :jira_issue, :project

      def initialize(project, jira_issue)
        @jira_issue = jira_issue
        @project = project
      end

      def execute
        Issue.new(
          project: project,
          title: jira_issue.summary,
          description: jira_issue.description,
          author_id: project.creator_id
        )
      end
    end
  end
end