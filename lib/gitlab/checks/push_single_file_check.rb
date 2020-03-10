# frozen_string_literal: true

module Gitlab
  module Checks
    class PushSingleFileCheck < BaseChecker
      attr_reader :commits, :logger

      LOG_MESSAGES = {
        diff_content_check: "Validating diff contents being single file..."
      }.freeze

      ERROR = "Creating/deleting files on snippet repositories is prohibited"

      def initialize(change, repository:, logger:)
        @commits = repository.new_commits(change[:newrev])
        @logger = logger
      end

      def validate!
        return if commits.empty?

        process_commits do |commit|
          validate_once(commit) do
            validate_commit(commit)
          end
        end
      end

      private

      def process_commits
        logger.log_timed(LOG_MESSAGES[:diff_content_check]) do
          # n+1: https://gitlab.com/gitlab-org/gitlab/issues/3593
          ::Gitlab::GitalyClient.allow_n_plus_1_calls do
            commits.each do |commit|
              logger.check_timeout_reached

              yield(commit)
            end
          end
        end
      end

      def validate_commit(commit)
        raw_deltas = commit.raw_deltas

        # When 3+ deltas exist, it can't be a single file operation
        raise_error if raw_deltas.size >= 3

        case raw_deltas.size
        when 1
          delta = raw_deltas.first
          if delta.deleted_file?
            raise_error
          elsif delta.new_file? && commit.repository.ls_files(commit.sha).size != 1 # allow creating file from empty repo
            raise_error
          end
        when 2
          # Rename may be recognized as creation + deletion if content change is too significant.
          delta1 = raw_deltas.first
          delta2 = raw_deltas.last

          renamed = (delta1.new_file? && delta2.deleted_file?) ||
                    (delta1.deleted_file? && delta2.new_file?)

          raise_error unless renamed
        end
      end

      def raise_error
        raise ::Gitlab::GitAccess::ForbiddenError, ERROR
      end
    end
  end
end
