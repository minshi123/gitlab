# frozen_string_literal: true

module Vulnerabilities
  class Export < ApplicationRecord
    include WithUploads

    self.table_name = "vulnerability_exports"

    belongs_to :project

    mount_uploader :file, AttachmentUploader

    EXPORT_FORMATS = {
      csv: 0
    }.with_indifferent_access.freeze

    enum format: EXPORT_FORMATS

    validates :project, presence: true
    validates :status, presence: true
    validates :format, presence: true
    validates :file, presence: true, if: :finished?

    state_machine :status, initial: :created do
      event :start do
        transition created: :running
      end

      event :finish do
        transition running: :finished
      end

      event :failed do
        transition [:created, :running] => :failed
      end

      state :created
      state :running
      state :finished
      state :failed

      before_transition created: :running do |export|
        export.started_at = Time.now
      end

      before_transition any => [:finished, :failed] do |export|
        export.finished_at = Time.now
      end
    end
  end
end
