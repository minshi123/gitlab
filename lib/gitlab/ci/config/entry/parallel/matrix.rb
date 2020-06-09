# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module Entry
        ##
        # Entry that represents matrix style parallel builds.
        #
        class Parallel
          class Matrix < ::Gitlab::Config::Entry::Node
            include ::Gitlab::Config::Entry::Validatable
            include ::Gitlab::Config::Entry::Attributable

            validations do
              validates :config, array_of_hashes: true
            end

            def compose!(deps = nil)
              super(deps) do
                [@config].flatten.each_with_index do |variables, index|
                  @entries[index] = ::Gitlab::Config::Entry::Factory.new(Entry::Parallel::Variables)
                    .value(variables)
                    .create!
                end

                @entries.each_value do |entry|
                  entry.compose!(deps)
                end
              end
            end

            def value
              @entries.values.map(&:value)
            end
          end
        end
      end
    end
  end
end
