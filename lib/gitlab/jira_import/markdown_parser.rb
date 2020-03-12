# frozen_string_literal: true

module Gitlab
  module JiraImport
    class MarkdownParser
      attr_accessor :text

      CONFLUENCE_UNPROCESSED_TAGS = %w(color panel).freeze

      def initialize(text)
        @text = text
      end

      def execute
        process_skipped_tags
        process_simple_substitutions
        process_links
        process_quotes
        process_code_snippets

        text
      end

      private

      def process_skipped_tags
        regexp_string = "({(?>color|panel)[^}]*}\\s*)([^{]*)({[^}]*})"
        regexp = Regexp.new(regexp_string)
        @text = text.gsub(regexp, '\2')
      end

      def process_simple_substitutions
        substitutions = {
          '#' => '1.',
          'h1.' => '#',
          'h2.' => '##',
          'h3.' => '###',
          'h4.' => '####',
          'h5.' => '#####',
          'h6.' => '######',
        }

        substitutions.each { |k, v| text.gsub!(k, v) }
      end

      def process_links
        regexp_string = "(\\[([^]|]+))\\|(([^]|]+))(>?\\|smart-link\\]|\\])"
        regexp = Regexp.new(regexp_string)
        @text = text.gsub(regexp, '[\2](\4)')
      end

      def process_quotes
        regexp_string = "({quote})([^{]*)({quote})"
        regexp = Regexp.new(regexp_string)
        @text = text.gsub(regexp, ">>>\n\\2\n>>>")
      end

      def process_code_snippets
        regexp_string = "({(code:)([a-z]*)})([^{]*)({code})"
        regexp = Regexp.new(regexp_string)
        @text = text.gsub(regexp, "```\\3\n\\4\n```")
      end
    end
  end
end