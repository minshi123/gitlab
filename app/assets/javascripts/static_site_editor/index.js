import Vue from 'vue';
import App from './components/app.vue';
import createStore from './store';
import createRouter from './router';

const initStaticSiteEditor = el => {
  const { projectId, path: sourcePath, returnUrl, baseUrl } = el.dataset;
  const isSupportedContent = 'isSupportedContent' in el.dataset;

  const store = createStore({
    initialState: {
      isSupportedContent,
      projectId,
      returnUrl,
      sourcePath,
      username: window.gon.current_username,
    },
  });
  const router = createRouter(baseUrl, store);

  return new Vue({
    el,
    store,
    router,
    components: {
      App,
    },
    render(createElement) {
      return createElement('app');
    },
  });
};

export default initStaticSiteEditor;
