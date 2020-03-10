# frozen_string_literal: true

module Vulnerabilities
  class ExportCsvService
    def initialize(findings_relation)
      @findings = findings_relation
    end

    def csv_data
      csv_builder.render
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def csv_builder
      @csv_builder ||= CsvBuilder.new(@findings.preload(:scanner), header_to_value_hash)
    end
    # rubocop: enable CodeReuse/ActiveRecord

    private

    def header_to_value_hash
      {
        'Scanner Type' => 'report_type',
        'Scanner Name' => 'scanner_name',
        'Vulnerability' => 'name',
        'Details' => 'description',
        'Additional Info' => -> (finding) { finding.metadata['message'] },
        'Severity' => 'severity',
        'CVE' => -> (finding) { finding.metadata['cve'] }
      }
    end
  end
end
