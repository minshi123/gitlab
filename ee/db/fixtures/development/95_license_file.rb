# frozen_string_literal: true

class Gitlab::Seeder::LicenseFile
  attr_reader :file_path

  def initialize(file_path)
    @file_path = file_path
  end

  def seed!
    if File.file?(file_path)
      file = File.open(file_path)

      ::License.create!(data_file: file)
    else
      puts "Skipped. Given file path is not a file."
    end
  end
end

Gitlab::Seeder.quiet do
  flag = 'SEED_LICENSE_FILE_PATH'

  if ENV[flag]
    seeder = Gitlab::Seeder::LicenseFile.new(ENV[flag])

    puts "Seeded License file from #{ENV[flag]}." if seeder.seed!
  else
    puts "Skipped. Use the `#{flag}` environment variable to seed the license file of the given path."
  end
end
