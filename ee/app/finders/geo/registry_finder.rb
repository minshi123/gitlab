# frozen_string_literal: true

module Geo
  class RegistryFinder
    include ::Gitlab::Utils::StrongMemoize

    attr_reader :current_node_id

    def initialize(current_node_id: nil)
      @current_node_id = current_node_id
    end

    private

    def current_node
      strong_memoize(:current_node) do
        GeoNode.find(current_node_id) if current_node_id
      end
    end
  end
end
