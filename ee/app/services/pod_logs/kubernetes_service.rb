# frozen_string_literal: true

module PodLogs
  class KubernetesService < BaseService
    LOGS_LIMIT = 500.freeze

    steps :check_param_lengths,
          :check_deployment_platform,
          :get_raw_pods,
          :get_pod_names,
          :check_pod_name,
          :check_container_name,
          :pod_logs,
          :force_logs_encoding_to_utf8,
          :encode_logs_to_utf8,
          :split_logs,
          :filter_return_keys

    self.reactive_cache_worker_finder = ->(id, _cache_key, params) { new(Environment.find(id), params: params) }

    private

    def pod_logs(result)
      result[:logs] = environment.deployment_platform.kubeclient.get_pod_log(
        result[:pod_name],
        environment.deployment_namespace,
        container: result[:container_name],
        tail_lines: LOGS_LIMIT,
        timestamps: true
      ).body

      success(result)
    rescue Kubeclient::ResourceNotFoundError
      error(_('Pod not found'))
    rescue Kubeclient::HttpError => e
      ::Gitlab::ErrorTracking.track_exception(e)

      error(_('Kubernetes API returned status code: %{error_code}') % {
        error_code: e.error_code
      })
    end

    def force_logs_encoding_to_utf8(result)
      return success(result) if result[:logs].encoding == Encoding::UTF_8

      result[:logs] = force_utf8(result[:logs])

      success(result)
    end

    def encode_logs_to_utf8(result)
      return success(result) if result[:logs].encoding == Encoding::UTF_8

      result[:logs] = result[:logs].encode(Encoding::UTF_8, invalid: :replace, undef: :replace)

      success(result)
    rescue Encoding => exception
      ::Gitlab::ErrorTracking.track_exception(exception)
      log_error("#{exception.class} #{exception.message}")

      error(_('Kubernetes logs could not be converted into UTF-8. Check Gitlab logs for errors.'))
    end

    def split_logs(result)
      result[:logs] = result[:logs].strip.lines(chomp: true).map do |line|
        # message contains a RFC3339Nano timestamp, then a space, then the log line.
        # resolution of the nanoseconds can vary, so we split on the first space
        values = line.split(' ', 2)
        {
          timestamp: values[0],
          message: values[1]
        }
      end

      success(result)
    end

    def force_utf8(logs)
      Gitlab::Utils.force_utf8(logs)
    rescue Encoding
      logs
    end

    def etag_path
      ::Gitlab::Routing.url_helpers.k8s_project_logs_path(
        environment.project,
        params.merge({
          environment_name: environment.name,
          format: :json
        })
      )
    end
  end
end
