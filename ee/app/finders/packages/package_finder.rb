# frozen_string_literal: true
module Packages
  class PackageFinder
    def initialize(project, package_id = nil, package_type = nil)
      @project = project
      @package_id = package_id
      @package_type = package_type
    end

    def execute
      if @package_id
        @project.packages.find(@package_id)
      elsif @package_type
        @project.packages.with_package_type(@package_type)
      else
        @project.packages
      end
    end
  end
end
