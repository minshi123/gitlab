# frozen_string_literal: true

module Elastic
  class MetricsUpdateService
    METRIC_PREFIX = 'geo_'.freeze

    def execute
      return unless elasticsearch_enabled?
      return unless prometheus_enabled?

      gauge = Gitlab::Metrics.gauge(:global_search_bulk_cron_queue_size, 'Number of database records waiting to be synchronized to Elasticsearch', {}, :max)
      gauge.set({}, Elastic::ProcessBookkeepingService.queue_size)
    end

    def elasticsearch_enabled?
      ::Gitlab::CurrentSettings.elasticsearch_indexing?
    end

    def prometheus_enabled?
      ::Gitlab::Metrics.prometheus_metrics_enabled?
    end
  end
end
