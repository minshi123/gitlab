# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        class Parallel
          class MatrixBuilds < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Attributable
            include ::Gitlab::Config::Entry::Configurable

            PERMITTED_KEYS = %i[matrix].freeze

            validations do
              validates :config, allowed_keys: PERMITTED_KEYS
              validates :config, required_keys: PERMITTED_KEYS
            end

            entry :matrix, Entry::Parallel::Matrix,
              description: 'Variables definition for matrix builds'
          end
        end
      end
    end
  end
end
