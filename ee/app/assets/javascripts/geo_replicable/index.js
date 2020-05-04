import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import createStore from './store';
import GeoReplicableApp from './components/app.vue';

Vue.use(Translate);

export default () => {
  const el = document.getElementById('js-geo-replicable');
  const { replicableType } = el.dataset;

  return new Vue({
    el,
    store: createStore(replicableType),
    components: {
      GeoReplicableApp,
    },
    data() {
      const {
        dataset: { geoReplicableEmptySvgPath },
      } = this.$options.el;

      return {
        geoReplicableEmptySvgPath,
      };
    },

    render(createElement) {
      return createElement('geo-replicable-app', {
        props: {
          geoReplicableEmptySvgPath: this.geoReplicableEmptySvgPath,
        },
      });
    },
  });
};
