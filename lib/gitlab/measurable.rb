# frozen_string_literal: true

module Gitlab
  # In order to measure and log execution of our service, we can just need to 'prepend Gitlab::Measurable'
  module Measurable
    extend ::Gitlab::Utils::Override

    override :execute
    def execute(*args)
      measuring? ? ::Gitlab::Utils::Measuring.new(base_log_data).with_measuring { super(*args) } : super(*args)
    end

    # We can redefine method :base_log_data to provide additional data to a log
    def base_log_data
      defined?(super) ? super : { class: self.class.name }
    end

    # We can redefine method :measuring to conditionally enable/disable measuring if needed, it is enabled by default
    def measuring?
      defined?(super) ? super : true
    end
  end
end
