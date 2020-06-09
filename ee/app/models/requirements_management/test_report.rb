# frozen_string_literal: true

module RequirementsManagement
  class TestReport < ApplicationRecord
    include Sortable
    include BulkInsertSafe

    belongs_to :requirement, inverse_of: :test_reports
    belongs_to :author, inverse_of: :test_reports, class_name: 'User'
    belongs_to :pipeline, class_name: 'Ci::Pipeline'
    belongs_to :build, class_name: 'Ci::Build'

    validates :requirement, :state, presence: true
    validate :validate_pipeline_reference

    enum state: { passed: 1, failed: 2, other: 3 }

    scope :for_user_build, ->(user_id, build_id) { where(author_id: user_id, build_id: build_id) }

    def self.persist_requirement_reports(build, ci_report)
      reports = []
      timestamp = Time.current

      iids = ci_report.requirements.keys
      return if iids.empty?

      build.project.requirements.opened.select(:id, :iid).where(iid: iids).each do |requirement|
        # Match the report to the requirement
        new_report = new(
          requirement_id: requirement.id,
          # pipeline_reference will be removed:
          # https://gitlab.com/gitlab-org/gitlab/-/issues/219999
          pipeline_id: build.pipeline_id,
          build_id: build.id,
          author_id: build.user_id,
          created_at: timestamp,
          state: to_valid_state(ci_report.requirements[requirement.iid.to_s])
        )

        reports << new_report
      end

      bulk_insert!(reports)
    end

    private

    def self.to_valid_state(new_state)
      return new_state if states.keys.include?(new_state)

      "other"
    end

    def validate_pipeline_reference
      if pipeline_id != build&.pipeline_id
        errors.add(:build, _('build pipeline reference mismatch'))
      end
    end
  end
end
