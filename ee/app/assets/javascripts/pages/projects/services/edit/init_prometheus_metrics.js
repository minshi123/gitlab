import PrometheusMetrics from 'ee/prometheus_metrics/prometheus_metrics';

export default () => {
  const prometheusSettingsWrapper = document.querySelector('.js-prometheus-metrics-monitoring');
  if (prometheusSettingsWrapper) {
    const prometheusMetrics = new PrometheusMetrics('.js-prometheus-metrics-monitoring');
    if (prometheusMetrics.isServiceActive) {
      prometheusMetrics.loadActiveCustomMetrics();
    } else {
      prometheusMetrics.setNoIntegrationActiveState();
    }
  }
};
