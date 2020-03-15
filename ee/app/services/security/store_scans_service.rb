# frozen_string_literal: true

module Security
  class StoreScansService
    def initialize(build)
      @build = build
    end

    def execute
      return if @build.canceled? || @build.skipped?

      ActiveRecord::Base.transaction do
        @build.each_report(::Ci::JobArtifact::SECURITY_REPORT_FILE_TYPES) do |file_type, blob, artifact|
          job_artifact_json = JSON.parse(blob)

          scanned_resource_count = job_artifact_json.fetch('scan', {}).fetch('scanned_resources', []).length

          Security::Scan.safe_find_or_create_by!(
            build: @build,
            scan_type: file_type,
            scanned_resources_count: scanned_resource_count
          )
        end
      end
    end
  end
end
