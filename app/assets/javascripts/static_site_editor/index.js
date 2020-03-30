import Vue from 'vue';
import StaticSiteEditor from './static_site_editor.vue';
import createStore from './store';

const initStaticSiteEditor = () => {
  const store = createStore();

  return new Vue({
    store,
    components: {
      StaticSiteEditor,
    },
    render(createElement) {
      return createElement('static-site-editor', StaticSiteEditor);
    }
  });
}

export default initStaticSiteEditor;
