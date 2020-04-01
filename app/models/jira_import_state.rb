# frozen_string_literal: true

class JiraImportState < ApplicationRecord
  include AfterCommitQueue

  self.table_name = "jira_imports"

  JIRA_IMPORT_STATUSES = { created: 0, scheduled: 1, started: 2, failed: 3, finished: 4 }.freeze

  belongs_to :project
  belongs_to :user
  belongs_to :label

  validates :project, presence: true
  validates :jira_project_key, presence: true
  validates :jira_project_name, presence: true
  validates :jira_project_xid, presence: true

  validates :project, uniqueness: {
    conditions: -> { where.not(status: JIRA_IMPORT_STATUSES.values_at(:failed, :finished)) },
    message: _('Cannot have multiple Jira imports running at the same time')
  }

  state_machine :status, initial: :created do
    event :schedule do
      transition [:created, :finished, :failed] => :scheduled
    end

    event :start do
      transition scheduled: :started
    end

    event :finish do
      transition started: :finished
    end

    event :do_fail do
      transition [:scheduled, :started] => :failed
    end

    state :created, value: JIRA_IMPORT_STATUSES[:created]
    state :scheduled, value: JIRA_IMPORT_STATUSES[:scheduled]
    state :started, value: JIRA_IMPORT_STATUSES[:started]
    state :finished, value: JIRA_IMPORT_STATUSES[:finished]
    state :failed, value: JIRA_IMPORT_STATUSES[:failed]

    after_transition [:created, :finished, :failed] => :scheduled do |state, _|
      state.run_after_commit do
        job_id = Gitlab::JiraImport::Stage::StartImportWorker.perform_async(self.id)
        update(jid: job_id) if job_id
      end
    end

    after_transition any => :finished do |state, _|
      if state.jid.present?
        Gitlab::SidekiqStatus.unset(state.jid)

        state.update_column(:jid, nil)
      end
    end

    after_transition started: :finished do |state, _|
      project = state.project

      project.reset_cache_and_import_attrs

      if Gitlab::ImportSources.importer_names.include?(project.import_type) && project.repo_exists?
        # rubocop: disable CodeReuse/ServiceClass
        state.run_after_commit do
          Projects::AfterImportService.new(project).execute
        end
        # rubocop: enable CodeReuse/ServiceClass
      end
    end
  end

  def in_progress?
    scheduled? || started?
  end

  def refresh_jid_expiration
    return unless jid

    Gitlab::SidekiqStatus.set(jid, StuckImportJobsWorker::IMPORT_JOBS_EXPIRATION)
  end

  def self.jid_by(project_id:, status:)
    select(:jid).with_status(status).find_by(project_id: project_id)
  end
end
