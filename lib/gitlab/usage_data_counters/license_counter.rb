# frozen_string_literal: true

module Gitlab::UsageDataCounters
  module LicenseCounter
    @counters = {}

    def self.counters
      @counters
    end

    def self.alt_usage_data(attribute_key, value = nil, &block)
      if block_given?
        @counters[attribute_key] = block
      else
        @counters[attribute_key] = value
      end
    end

    alt_usage_data :uuid do
      Gitlab::CurrentSettings.uuid
    end

    alt_usage_data :installation_type do
      installation_type
    end

    alt_usage_data :hostname do
      Gitlab.config.gitlab.host
    end

    alt_usage_data :version do
      Gitlab::VERSION
    end

    alt_usage_data :active_user_count do
      count(User.active)
    end

    alt_usage_data :recorded_at do
      Time.now
    end

    alt_usage_data :edition, 'CE'

    def self.data(context)
      @counters.each_with_object({}) do |counter, result|

        value = if counter[1].is_a?(Proc)
          context.instance_eval(&counter[1])
        else
          counter[1]
        end

        result[counter[0]] = value
      end
    end
  end
end
