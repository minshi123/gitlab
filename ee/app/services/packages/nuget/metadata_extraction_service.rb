# frozen_string_literal: true

module Packages
  module Nuget
    class MetadataExtractionService
      include Gitlab::Utils::StrongMemoize

      ExtractionError = Class.new(StandardError)

      attr_reader :package_filepath

      XPATHS = {
        package_name: '//xmlns:package/xmlns:metadata/xmlns:id',
        package_version: '//xmlns:package/xmlns:metadata/xmlns:version'
      }.freeze

      MAX_FILE_SIZE = 4.megabytes.freeze

      def initialize(package_filepath)
        @package_filepath = package_filepath
      end

      def execute
        raise ExtractionError.new('invalid package file') unless valid_filepath?

        doc = Nokogiri::XML(nuspec_file)

        XPATHS.map do |key, query|
          [key, doc.xpath(query).text]
        end.to_h
      end

      private

      def valid_filepath?
        File.file?(package_filepath) && !File.zero?(package_filepath)
      end

      def nuspec_file
        Zip::File.open(package_filepath) do |zip_file|
          entry = zip_file.glob('*.nuspec').first

          raise ExtractionError.new('nuspec file not found') unless entry
          raise ExtractionError.new('nuspec file too big') if entry.size > MAX_FILE_SIZE

          entry.get_input_stream.read
        end
      end
    end
  end
end
