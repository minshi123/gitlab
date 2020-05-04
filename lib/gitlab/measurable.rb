# frozen_string_literal: true

module Gitlab
  module Measurable
    attr_accessor :measuring
    alias_method :measuring?, :measuring

    def execute(*args)
      measuring? ? ::Gitlab::Utils::Measuring.new(base_log_data).with_measuring { service_execute(*args) } : service_execute(*args)
    end

    def base_log_data
      { class: self.class.name }
    end

    def service_execute(*_args)
      raise NotImplementedError
    end
  end
end
