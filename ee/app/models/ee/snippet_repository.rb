# frozen_string_literal: true

module EE
  module SnippetRepository
    extend ActiveSupport::Concern

    prepended do
      include ::Gitlab::Geo::ReplicableModel
      with_replicator Geo::SnippetRepositoryReplicator
    end

    class_methods do

    end
  end
end
