# frozen_string_literal: true

module VulnerabilitiesHelper
  def vulnerability_data(vulnerability, pipeline)
    return unless vulnerability

    vulnerability_data = {
        id: vulnerability.id,
        description: vulnerability.finding.description,
        category: vulnerability.report_type,
        confidence: vulnerability.confidence,
        identifiers: vulnerability.finding.identifiers,
        issue_feedback: vulnerability.finding.issue_feedback,
        links: vulnerability.finding.links,
        location: vulnerability.finding.location,
        project_fingerprint: vulnerability.finding.project_fingerprint,
        remediations: vulnerability.finding.remediations,
        report_type: vulnerability.report_type,
        severity: vulnerability.severity,
        solution: vulnerability.finding.solution,
        state: vulnerability.state,
        title: vulnerability.title
    }

    {
      vulnerability_json: vulnerability_data.to_json,
      create_issue_url: create_vulnerability_feedback_issue_path(vulnerability.finding.project),
      pipeline_json: vulnerability_pipeline_data(pipeline).to_json,
    }
  end

  def vulnerability_pipeline_data(pipeline)
    return unless pipeline

    {
      id: pipeline.id,
      created_at: pipeline.created_at.iso8601,
      url: pipeline_path(pipeline)
    }
  end
end
