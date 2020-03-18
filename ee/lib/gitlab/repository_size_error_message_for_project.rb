# frozen_string_literal: true

module Gitlab
  class RepositorySizeErrorMessageForProject < RepositorySizeErrorMessage
    def initialize(project)
      super(
        current_size: project.repository_and_lfs_size,
        limit: project.actual_size_limit
      )
    end

    def above_size_limit_message
      "#{self} You won't be able to push new code to this project. #{more_info_message}"
    end

    def merge_error
      "This merge request cannot be merged, #{base_message}"
    end
  end
end
