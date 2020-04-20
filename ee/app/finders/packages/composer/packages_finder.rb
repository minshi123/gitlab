# frozen_string_literal: true
class Packages::Composer::PackagesFinder < Packages::GroupPackagesFinder
  attr_reader :current_user, :group

  def initialize(current_user, group, params = {})
    @current_user = current_user
    @group = group
    @params = params
  end

  def execute
    packages_for_group_projects.composer
  end
end
