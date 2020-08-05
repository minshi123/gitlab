# frozen_string_literal: true

module Geo
  class SnippetRepositoryReplicator < Gitlab::Geo::Replicator
    # include ::Geo::RepositoryReplicatorStrategy

    def self.model
      ::SnippetRepository
    end
  end
end
