import PrometheusMetrics from '~/prometheus_metrics/prometheus_metrics';

export default () => {
  const prometheusSettingsWrapper = document.querySelector('.js-prometheus-metrics-monitoring');
  if (prometheusSettingsWrapper) {
    const prometheusMetrics = new PrometheusMetrics('.js-prometheus-metrics-monitoring');
    prometheusMetrics.loadActiveMetrics();
  }
};
