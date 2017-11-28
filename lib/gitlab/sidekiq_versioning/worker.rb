# frozen_string_literal: true

module Gitlab
  module SidekiqVersioning
    module Worker
      extend ActiveSupport::Concern

      included do
        version 0

        attr_accessor :job_version
      end

      class_methods do
        def version(new_version = nil)
          if new_version
            sidekiq_options version: new_version.to_i
          else
            get_sidekiq_options['version']
          end
        end
      end

      def support_job_version?(job_version = self.job_version)
        job_version <= self.class.version
      end
    end
  end
end
