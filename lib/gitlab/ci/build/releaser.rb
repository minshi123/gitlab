# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Releaser
        attr_reader :config

        def initialize(config:)
          @config = config
        end

        def script
          command = base_command.dup
          config.each { |k, v| command.concat(" --#{k.to_s.dasherize} \"#{v}\"") }

          command
        end

        private

        def base_command
          'release-cli create'
        end
      end
    end
  end
end
