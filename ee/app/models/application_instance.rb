# frozen_string_literal: true

class ApplicationInstance
  extend ActiveModel::Naming
  include ::Vulnerable

  def all_pipelines
    ::Ci::Pipeline.all
  end

  def flipper_id
    self.class
  end
end
