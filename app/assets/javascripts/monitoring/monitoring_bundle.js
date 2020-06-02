import Vue from 'vue';
import { GlToast } from '@gitlab/ui';
import { stateAndPropsFromDataset } from '~/monitoring/utils';
import Dashboard from '~/monitoring/components/dashboard.vue';
import { getParameterValues } from '~/lib/utils/url_utility';
import { createStore } from './stores';

Vue.use(GlToast);

export default (props = {}) => {
  const el = document.getElementById('prometheus-graphs');

  if (el && el.dataset) {
    const [currentDashboard] = getParameterValues('dashboard');
    const { initState, dataProps } = stateAndPropsFromDataset({ currentDashboard, ...el.dataset });

    // eslint-disable-next-line no-new
    new Vue({
      el,
      store: createStore(initState),
      render(createElement) {
        return createElement(Dashboard, {
          props: {
            ...dataProps,
            ...props,
          },
        });
      },
    });
  }
};
