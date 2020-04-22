# frozen_string_literal: true

module Namespaces
  class CheckStorageSizeService
    def initialize(namespace)
      @root_namespace = namespace.root_ancestor
      @root_storage_size = Namespace::RootStorageSize.new(root_namespace)
    end

    def execute
      return ServiceResponse.success unless Feature.enabled?(:namespace_storage_limit, root_namespace)

      if root_storage_size.above_size_limit?
        ServiceResponse.error(message: s_("Namespace exceeded the storage limit"))
      else
        ServiceResponse.success
      end
    end

    private

    attr_reader :root_namespace, :root_storage_size
  end
end
