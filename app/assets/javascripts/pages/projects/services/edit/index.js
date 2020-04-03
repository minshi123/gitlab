import IntegrationSettingsForm from '~/integrations/integration_settings_form';
import PrometheusAlerts from '~/prometheus_alerts';
import initAlertsSettings from '~/alerts_service_settings';
import initPrometheusMetrics from 'ee_else_ce/pages/projects/services/edit/init_prometheus_metrics';

document.addEventListener('DOMContentLoaded', () => {
  const integrationSettingsForm = new IntegrationSettingsForm('.js-integration-settings-form');
  integrationSettingsForm.init();

  PrometheusAlerts();
  initAlertsSettings(document.querySelector('.js-alerts-service-settings'));

  initPrometheusMetrics();
});
