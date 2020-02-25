# frozen_string_literal: true
module Packages
  class PackageTypeFinder
    def initialize(project, params)
      @project = project
      @package_type = params.fetch(:package_type, nil)
    end

    def execute
      @packages = @project.packages

      filter_by_package_type
    end

    private

    def filter_by_package_type
      return unless @package_type

      @packages = @packages.with_package_type(@package_type)
    end
  end
end
