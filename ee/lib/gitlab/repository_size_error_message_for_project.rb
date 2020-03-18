# frozen_string_literal: true

module Gitlab
  class RepositorySizeErrorMessageForProject
    include RepositorySizeErrorMessage

    attr_reader :project

    def initialize(project)
      @project = project
    end

    def above_size_limit_message
      "#{self} You won't be able to push new code to this project. #{more_info_message}"
    end

    def merge_error
      "This merge request cannot be merged, #{base_message}"
    end

    private

    def current_size
      @current_size ||= project.repository_and_lfs_size
    end

    def limit
      @limit ||= project.actual_size_limit
    end
  end
end
