# frozen_string_literal: true

module Gitlab
  module Measurable
    attr_accessor :measuring
    alias_method :measuring?, :measuring

    def execute(*args)
      measuring? ? ::Gitlab::Utils::Measuring.new(base_log_data).with_measuring { safe_execute(*args) } : safe_execute(*args)
    end

    def base_log_data
      {}
    end

    def safe_execute(*_args); end
  end
end
