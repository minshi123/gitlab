import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
// import Dashboard from '~/monitoring/components/dashboard.vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import { getParameterValues } from '~/lib/utils/url_utility';
import { createStore } from './stores';
import createRouter from './router';

Vue.use(GlToast);

export default () => {
  const el = document.getElementById('prometheus-graphs');
  const { dataset } = el;
  const store = createStore();
  const router = createRouter();
  const [currentDashboard] = getParameterValues('dashboard');

  store.dispatch('monitoringDashboard/setInitialState', {
    // dynamic, should pased as route params
    currentDashboard,
    currentEnvironmentName: dataset.currentEnvironmentName,

    // static
    metricsEndpoint: dataset.metricsEndpoint,
    deploymentsEndpoint: dataset.deploymentsEndpoint,
    dashboardEndpoint: dataset.dashboardEndpoint,
    dashboardsEndpoint: dataset.dashboardsEndpoint,
    projectPath: dataset.projectPath,
    logsPath: dataset.logsPath,

    // booleans
    customMetricsAvailable: parseBoolean(dataset.customMetricsAvailable),
    prometheusAlertsAvailable: parseBoolean(dataset.prometheusAlertsAvailable),
    hasMetrics: parseBoolean(dataset.hasMetrics),
  });

  return new Vue({
    el,
    store,
    router,
    template: `<router-view />`,
  });
};
