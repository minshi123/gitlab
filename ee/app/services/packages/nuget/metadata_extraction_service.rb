# frozen_string_literal: true

module Packages
  module Nuget
    class MetadataExtractionService
      include Gitlab::Utils::StrongMemoize

      attr_reader :package_file_id

      XPATHS = {
        package_name: '//xmlns:package/xmlns:metadata/xmlns:id',
        package_version: '//xmlns:package/xmlns:metadata/xmlns:version'
      }.freeze

      MAX_FILE_SIZE = 4.megabytes.freeze

      def initialize(package_file_id)
        @package_file_id = package_file_id
      end

      def execute
        raise ArgumentError, 'invalid package file' unless valid_package_file?

        extract_metadata(nuspec_file)
      end

      private

      def package_file
        strong_memoize(:package_file) do
          ::Packages::PackageFile.id_in(package_file_id)
                                 .first
        end
      end

      def valid_package_file?
        package_file &&
          package_file.package&.nuget? &&
          package_file.size != 0.bytes
      end

      def extract_metadata(file)
        doc = Nokogiri::XML(file)

        Hash.new { |h, k| h[k] = doc.xpath(XPATHS[k]).text }.tap do |metadata|
          XPATHS.keys.each { |k| metadata[k] }
        end
      end

      def nuspec_file
        package_file.file.use_file do |file_path|
          Zip::File.open(file_path) do |zip_file|
            entry = zip_file.glob('*.nuspec').first

            raise ArgumentError, 'nuspec file not found' unless entry
            raise ArgumentError, 'nuspec file too big' if entry.size > MAX_FILE_SIZE

            entry.get_input_stream.read
          end
        end
      end
    end
  end
end
