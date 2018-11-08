# frozen_string_literal: true

module Clusters
  module Gcp
    module Kubernetes
      class CreateServiceAccountService
        def initialize(kubeclient, service_account_name:, service_account_namespace:, token_name:, rbac:, namespace_creator: false, role_binding_name: nil)
          @kubeclient = kubeclient
          @service_account_name = service_account_name
          @service_account_namespace = service_account_namespace
          @token_name = token_name
          @rbac = rbac
          @namespace_creator = namespace_creator
          @role_binding_name = role_binding_name
        end

        def self.gitlab_creator(kubeclient, rbac:)
          self.new(
            kubeclient,
            service_account_name: Clusters::Gcp::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAME,
            service_account_namespace: Clusters::Gcp::Kubernetes::GITLAB_SERVICE_ACCOUNT_NAMESPACE,
            token_name: Clusters::Gcp::Kubernetes::GITLAB_ADMIN_TOKEN_NAME,
            rbac: rbac
          )
        end

        def self.namespace_creator(kubeclient, service_account_name:, service_account_namespace:, rbac:)
          self.new(
            kubeclient,
            service_account_name: service_account_name,
            service_account_namespace: service_account_namespace,
            token_name: "#{service_account_namespace}-token",
            rbac: rbac,
            namespace_creator: true,
            role_binding_name: "gitlab-#{service_account_namespace}"
          )
        end

        def execute
          ensure_project_namespace_exists if namespace_creator
          kubeclient.create_service_account(service_account_resource)
          kubeclient.create_secret(service_account_token_resource)
          create_role_or_cluster_role_binding if rbac
        end

        private

        attr_reader :kubeclient, :service_account_name, :service_account_namespace, :token_name, :rbac, :namespace_creator, :role_binding_name

        def ensure_project_namespace_exists
          Gitlab::Kubernetes::Namespace.new(
            service_account_namespace,
            kubeclient
          ).ensure_exists!
        end

        def create_role_or_cluster_role_binding
          if namespace_creator
            kubeclient.create_role_binding(role_binding_resource)
          else
            kubeclient.create_cluster_role_binding(cluster_role_binding_resource)
          end
        end

        def service_account_resource
          Gitlab::Kubernetes::ServiceAccount.new(
            service_account_name,
            service_account_namespace
          ).generate
        end

        def service_account_token_resource
          Gitlab::Kubernetes::ServiceAccountToken.new(
            token_name,
            service_account_name,
            service_account_namespace
          ).generate
        end

        def cluster_role_binding_resource
          subjects = [{ kind: 'ServiceAccount', name: service_account_name, namespace: service_account_namespace }]

          Gitlab::Kubernetes::ClusterRoleBinding.new(
            Clusters::Gcp::Kubernetes::GITLAB_CLUSTER_ROLE_BINDING_NAME,
            Clusters::Gcp::Kubernetes::GITLAB_CLUSTER_ROLE_NAME,
            subjects
          ).generate
        end

        def role_binding_resource
          Gitlab::Kubernetes::RoleBinding.new(
            name: role_binding_name,
            role_name: Clusters::Gcp::Kubernetes::PROJECT_CLUSTER_ROLE_NAME,
            namespace: service_account_namespace,
            service_account_name: service_account_name
          ).generate
        end
      end
    end
  end
end
