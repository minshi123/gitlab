import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import StaticSiteEditor from './components/static_site_editor.vue';
import createStore from './store';
import createApolloProvider from './graphql';

const initStaticSiteEditor = el => {
  const { isSupportedContent, projectId, path: sourcePath, returnUrl } = el.dataset;
  const { current_username: username } = window.gon;

  const store = createStore({
    initialState: {
      isSupportedContent: parseBoolean(isSupportedContent),
      projectId,
      returnUrl,
      sourcePath,
      username,
    },
  });
  const apolloProvider = createApolloProvider({
    isSupportedContent: parseBoolean(isSupportedContent),
    projectId,
    returnUrl,
    sourcePath,
    username,
  });

  return new Vue({
    el,
    store,
    apolloProvider,
    components: {
      StaticSiteEditor,
    },
    render(createElement) {
      return createElement('static-site-editor', StaticSiteEditor);
    },
  });
};

export default initStaticSiteEditor;
