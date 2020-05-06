# frozen_string_literal: true

module EE
  module API
    module Entities
      class PackageVersion < Grape::Entity
        expose :id
        expose :version
        expose :created_at
        expose :tags

        expose :pipeline, if: ->(package) { package.build_info }, using: Package::Pipeline

        private

        def pipeline
          object.build_info.pipeline
        end
      end
    end
  end
end
