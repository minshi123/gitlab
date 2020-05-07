# frozen_string_literal: true

# Create a separate process, which does not load the Rails environment, to index
# each repository. This prevents memory leaks in the indexer from affecting the
# rest of the application.
module Gitlab
  module Elastic
    class Indexer
      include Gitlab::Utils::StrongMemoize

      Error = Class.new(StandardError)

      class << self
        def indexer_version
          Rails.root.join('GITLAB_ELASTICSEARCH_INDEXER_VERSION').read.chomp
        end
      end

      attr_reader :project, :index_status, :wiki

      def initialize(project, wiki: false)
        @project = project
        @wiki = wiki

        # Use the eager-loaded association if available.
        @index_status = project.index_status
      end

      # Runs the indexation process, which is the following:
      # - Purge the index for any unreachable commits;
      # - Run the `gitlab-elasticsearch-indexer`;
      # - Update the `index_status` for the associated project;
      #
      # ref - Git ref up to which the indexation will run (default: 'master')
      def run(ref = 'master')
        to_sha ||= repository&.commit(ref)&.sha
        return update_index_status(Gitlab::Git::BLANK_SHA) unless commit_indexable?(to_sha)

        repository.__elasticsearch__.elastic_writing_targets.each do |target|
          Sidekiq.logger.debug(message: "Indexation running for #{project.id} #{from_sha}..#{to_sha}",
                               project_id: project.id,
                               wiki: wiki?)
          run_indexer!(to_sha, target)
        end

        # update the index status only if all writes where successful
        update_index_status(to_sha)

        true
      end

      private

      def wiki?
        @wiki
      end

      def repository
        wiki ? project.wiki.repository : project.repository
      end

      def run_indexer!(to_sha, target)
        vars = build_envvars(to_sha, target)
        path_to_indexer = Gitlab.config.elasticsearch.indexer_path

        # This might happen when default branch has been rebased.
        purge_unreachable_commits_from_index!(to_sha, target)

        command =
          if wiki?
            [path_to_indexer, "--blob-type=wiki_blob", "--skip-commits", project.id.to_s, repository_path]
          else
            [path_to_indexer, project.id.to_s, repository_path]
          end

        output, status = Gitlab::Popen.popen(command, nil, vars)

        raise Error, output unless status&.zero?
      end

      # Remove all indexed data for commits and blobs for a project.
      def purge_unreachable_commits_from_index!(to_sha, target)
        unless last_commit_ancestor_of?(to_sha)
          target.delete_index_for_commits_and_blobs(wiki: wiki?)
        end
      end

      def build_envvars(to_sha, target)
        # We accept any form of settings, including string and array
        # This is why JSON is needed
        vars = {
          'RAILS_ENV'               => Rails.env,
          'ELASTIC_CONNECTION_INFO' => elasticsearch_config(target),
          'GITALY_CONNECTION_INFO'  => gitaly_connection_info,
          'FROM_SHA'                => from_sha,
          'TO_SHA'                  => to_sha,
          'CORRELATION_ID'          => Labkit::Correlation::CorrelationId.current_id,
          'SSL_CERT_FILE'           => OpenSSL::X509::DEFAULT_CERT_FILE,
          'SSL_CERT_DIR'            => OpenSSL::X509::DEFAULT_CERT_DIR
        }

        # Users can override default SSL certificate path via these envs
        %w(SSL_CERT_FILE SSL_CERT_DIR).each_with_object(vars) do |key, hash|
          hash[key] = ENV[key] if ENV.key?(key)
        end
      end

      def last_commit
        if wiki?
          index_status&.last_wiki_commit
        else
          index_status&.last_commit
        end
      end

      def from_sha
        repository_contains_last_indexed_commit? ? last_commit : Gitlab::Git::EMPTY_TREE_ID
      end

      def repository_contains_last_indexed_commit?
        strong_memoize(:repository_contains_last_indexed_commit) do
          last_commit.present? && repository.commit(last_commit).present?
        end
      end

      def last_commit_ancestor_of?(to_sha)
        from_sha != Gitlab::Git::EMPTY_TREE_ID && repository.ancestor?(from_sha, to_sha)
      end

      def commit_indexable?(rev = nil)
        repository.present? && repository.exists? && !repository.empty? && repository&.commit(rev).present?
      end

      def repository_path
        "#{repository.disk_path}.git"
      end

      def elasticsearch_config(target)
        Gitlab::CurrentSettings.elasticsearch_config.merge(
          index_name: target.index_name
        ).to_json
      end

      def gitaly_connection_info
        {
          storage: project.repository_storage
        }.merge(Gitlab::GitalyClient.connection_data(project.repository_storage)).to_json
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def update_index_status(to_sha)
        raise "Invalid sha #{to_sha}" unless to_sha.present?

        # An index_status should always be created,
        # even if the repository is empty, so we know it's been looked at.
        @index_status ||=
          begin
            IndexStatus.find_or_create_by(project_id: project.id)
          rescue ActiveRecord::RecordNotUnique
            retry
          end

        attributes =
          if wiki?
            { last_wiki_commit: to_sha, wiki_indexed_at: Time.now }
          else
            { last_commit: to_sha, indexed_at: Time.now }
          end

        @index_status.update(attributes)
        project.reload_index_status
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
