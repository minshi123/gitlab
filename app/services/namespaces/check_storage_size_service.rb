# frozen_string_literal: true

module Namespaces
  class CheckStorageSizeService
    def initialize(namespace, user)
      @root_namespace = namespace.root_ancestor
      @root_storage_size = Namespace::RootStorageSize.new(root_namespace)
      @root_storage_limit_alert = Namespace::RootStorageLimitAlert.new(root_namespace, root_storage_size, user)
    end

    def execute
      return ServiceResponse.success unless Feature.enabled?(:namespace_storage_limit, root_namespace)

      if root_storage_size.above_size_limit?
        ServiceResponse.error(message: above_size_limit_message, payload: payload)
      else
        ServiceResponse.success(message: info_message, payload: payload)
      end
    end

    private

    attr_reader :root_namespace, :root_storage_size, :root_storage_limit_alert

    def payload
      {
        alert: root_storage_limit_alert,
        storage_size: root_storage_size
      }
    end
  end
end
