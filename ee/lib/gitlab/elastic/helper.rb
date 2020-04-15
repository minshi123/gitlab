# frozen_string_literal: true

module Gitlab
  module Elastic
    class Helper
      class << self
        def create_proxy(version = nil)
          Project.__elasticsearch__.version(version)
        end
      end

      attr_reader :version, :client
      attr_accessor :index_name

      def initialize(
        version: ::Elastic::MultiVersionUtil::TARGET_VERSION,
        client: nil,
        index_name: nil)

        proxy = self.class.create_proxy(version)

        @client = client || proxy.client
        @index_name = index_name || proxy.index_name
        @version = version
      end

      # rubocop: disable CodeReuse/ActiveRecord
      def create_empty_index
        settings = {}
        mappings = {}

        [
          Project,
          Issue,
          MergeRequest,
          Snippet,
          Note,
          Milestone,
          ProjectWiki,
          Repository
        ].each do |klass|
          settings.deep_merge!(klass.__elasticsearch__.settings.to_hash)
          mappings.deep_merge!(klass.__elasticsearch__.mappings.to_hash)
        end

        create_index_options = {
          index: index_name,
          body: {
            settings: settings.to_hash,
            mappings: mappings.to_hash
          }
        }

        # include_type_name defaults to false in ES7. This will ensure ES7
        # behaves like ES6 when creating mappings. See
        # https://www.elastic.co/blog/moving-from-types-to-typeless-apis-in-elasticsearch-7-0
        # for more information. We also can't set this for any versions before
        # 6.8 as this parameter was not supported. Since it defaults to true in
        # all 6.x it's safe to only set it for 7.x.
        if Gitlab::VersionInfo.parse(client.info['version']['number']).major == 7
          create_index_options[:include_type_name] = true
        end

        if client.indices.exists?(index: index_name)
          raise "Index '#{index_name}' already exists, use `recreate_index` to recreate it."
        end

        client.indices.create create_index_options
      end
      # rubocop: enable CodeReuse/ActiveRecord

      def reindex_to_another_cluster(source_cluster_url, destination_cluster_url)
        destination_helper = self.class.new(version: version,
                                            client: Gitlab::Elastic::Client.build(url: destination_cluster_url))

        optimize_for_write_settings = { index: { number_of_replicas: 0, refresh_interval: "-1" } }

        destination_helper.create_empty_index
        destination_helper.client.indices.put_settings(index: index_name, body: optimize_for_write_settings)

        source_addressable = Addressable::URI.parse(source_cluster_url)

        response = destination_helper.client.reindex(body: {
          source: {
            remote: {
              host: source_addressable.omit(:user, :password).to_s,
              username: source_addressable.user,
              password: source_addressable.password
            },
            index: index_name
          },
          dest: {
            index: index_name
          }
        }, wait_for_completion: false)

        response['task']
      end

      def delete_index
        client.indices.delete(index: index_name)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
        raise "Index '#{index_name}' does not exist"
      end

      def index_exists?
        # TODO mbergeron: support aliases?
        client.indices.exists?(index: index_name) # rubocop:disable CodeReuse/ActiveRecord
      end

      # Calls Elasticsearch refresh API to ensure data is searchable
      # immediately.
      # https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-refresh.html
      def refresh_index
        client.indices.refresh(index: index_name)
      end

      def index_size
        client.indices.stats['indices'][index_name]['total']
      end
    end
  end
end
