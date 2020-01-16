# frozen_string_literal: true
class Gitlab::Seeder::Packages
  attr_reader :user, :project

  def initialize(user, project)
    @user = user
    @project = project
  end

  def seed_npm_packages
    5.times do |i|
      package_name = "@#{@project.full_path}-npm"
      version = "1.12.#{i}"

      fixture_json = File.read(Rails.root.join('ee', 'spec', 'fixtures', 'npm', 'payload.json'))

      params = JSON.parse(
        fixture_json
          .gsub('@root/npm-test', package_name)
          .gsub('1.0.1', version))
        .with_indifferent_access

      ::Packages::Npm::CreatePackageService.new(project, user, params).execute
      print '.'
    end
  end

  def seed_maven_packages
    5.times do |i|
      path = "my/company/app/maven-app"
      version = "1.0.#{i}-SNAPSHOT"

      params = {
        path: "#{path}/#{version}",
        name: path,
        version: version
      }

      ::Packages::CreateMavenPackageService.new(project, user, params).execute
      print '.'
    end
  end

  def seed_conan_packages
    5.times do |i|
      params = {
        package_name: 'my-conan-pkg',
        package_version: "1.0.#{i}",
        package_username: ::Packages::ConanMetadatum.package_username_from(full_path: project.full_path),
        package_channel: 'stable'
      }

      ::Packages::Conan::CreatePackageService.new(project, user, params).execute
      print '.'
    end
  end

  def seed_nuget_packages
    5.times do |i|
      pkg = ::Packages::Nuget::CreatePackageService.new(project, user, {}).execute
      pkg.update!(name: 'MyNugetApp.Package', version: "1.4.#{i}")
      print '.'
    end
  end
end

Gitlab::Seeder.quiet do
  flag = 'SEED_ALL_PACKAGE_TYPES'

  package_types = ENV[flag] ? %i[npm maven conan nuget] : [:npm]

  Project.not_mass_generated.sample(5).each do |project|
    puts "\nSeeding packages for the '#{project.full_path}' project"

    package_types.each do |package_type|
      Gitlab::Seeder::Packages.new(project.owner, project).send("seed_#{package_type}_packages")
    end
  end
end
