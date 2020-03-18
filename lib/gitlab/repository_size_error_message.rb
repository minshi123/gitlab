# frozen_string_literal: true

module Gitlab
  class RepositorySizeErrorMessage
    include ActiveSupport::NumberHelper

    attr_reader :current_size, :limit

    def initialize(current_size:, limit:)
      @current_size = current_size
      @limit = limit
    end

    def to_s
      "The size of this repository (#{formatted(current_size)}) exceeds the limit of #{formatted(limit)} by #{formatted(size_to_remove)}."
    end

    def commit_error
      "Your changes could not be committed, #{base_message}"
    end

    def push_error(exceeded_limit = nil)
      "Your push has been rejected, #{base_message(exceeded_limit)}. #{more_info_message}"
    end

    def new_changes_error
      "Your push to this repository would cause it to exceed the size limit of #{formatted(limit)} so it has been rejected. #{more_info_message}"
    end

    def more_info_message
      'Please contact your GitLab administrator for more information.'
    end

    private

    def base_message(exceeded_limit = nil)
      "because this repository has exceeded its size limit of #{formatted(limit)} by #{formatted(size_to_remove(exceeded_limit))}"
    end

    def size_to_remove(exceeded_limit = nil)
      exceeded_limit || (current_size - limit)
    end

    def formatted(number)
      number_to_human_size(number, delimiter: ',', precision: 2)
    end
  end
end
