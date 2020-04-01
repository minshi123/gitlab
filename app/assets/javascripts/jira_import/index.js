import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import App from './components/jira_import_app.vue';

Vue.use(VueApollo);

const defaultClient = createDefaultClient();

const apolloProvider = new VueApollo({
  defaultClient,
});

export default function mountJiraImportApp() {
  const el = document.querySelector('.js-jira-import-root');

  // eslint-disable-next-line no-new
  new Vue({
    el,
    apolloProvider,
    render(createComponent) {
      return createComponent(App, {
        props: {
          projectPath: el.dataset.projectPath,
        },
      });
    },
  });
}
