# frozen_string_literal: true

module Security
  class StoreScansService
    def initialize(build)
      @build = build
    end

    def execute
      return if @build.canceled? || @build.skipped?

      security_reports = @build.job_artifacts.security_reports

      ActiveRecord::Base.transaction do
        security_reports.each do |job_artifact|
          report = ::Gitlab::Ci::Reports::Security::Report.new(job_artifact.file_type, @build.pipeline.sha, job_artifact.created_at)
          ::Gitlab::Ci::Parsers.fabricate!(job_artifact.file_type).parse!(job_artifact.blob,report)

          Security::Scan.safe_find_or_create_by!(
            build: @build,
            scan_type: job_artifact.file_type,
            scanned_resources_count: report.scanned_resources_count
          )
        end
      end
    end
  end
end
