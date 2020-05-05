# frozen_string_literal: true

module Gitlab
  module Measurable
    def execute(*args)
      measuring? ? ::Gitlab::Utils::Measuring.new(base_log_data).with_measuring { super(*args) } : super(*args)
    end

    def base_log_data
      { class: self.class.name }
    end

    def measuring?
      false
    end
  end
end
