# frozen_string_literal: true

class ApplicationInstance
  extend ActiveModel::Naming
  include ::Vulnerable

  def initialize(project_ids:)
    @project_ids = project_ids
  end

  def all_pipelines
    ::Ci::Pipeline.where(project_id: project_ids)
  end

  def project_ids_with_security_reports
    project_ids
  end

  private

  attr_reader :project_ids
end
