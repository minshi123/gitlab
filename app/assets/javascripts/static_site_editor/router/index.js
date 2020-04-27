import Vue from 'vue';
import VueRouter from 'vue-router';
import routes from './routes';
import { doNotDisplaySuccessPage } from './guards';

Vue.use(VueRouter);

export default function createRouter(base, store) {
  const router = new VueRouter({
    base,
    mode: 'history',
    routes,
  });

  router.beforeEach(doNotDisplaySuccessPage(store));

  return router;
}
