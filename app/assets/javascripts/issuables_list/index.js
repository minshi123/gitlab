import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import { parseBoolean } from '~/lib/utils/common_utils';
import IssuableListRootApp from './components/issuable_list_root_app.vue';
import IssuablesListApp from './components/issuables_list_app.vue';

export default function initIssuablesList() {
  const element = document.querySelector('.js-projects-issues-root');
  if (element) {
    Vue.use(VueApollo);

    const defaultClient = createDefaultClient();

    const apolloProvider = new VueApollo({
      defaultClient,
    });

    // eslint-disable-next-line no-new
    new Vue({
      el: element,
      apolloProvider,
      render(createComponent) {
        return createComponent(IssuableListRootApp, {
          props: {
            isJiraConfigured: parseBoolean(element.dataset.isJiraConfigured),
            projectPath: element.dataset.projectPath,
          },
        });
      },
    });
  }

  if (gon.features?.vueIssuablesList) {
    document.querySelectorAll('.js-issuables-list').forEach(el => {
      const { canBulkEdit, ...data } = el.dataset;

      const props = {
        ...data,
        canBulkEdit: Boolean(canBulkEdit),
      };

      return new Vue({
        el,
        render(createElement) {
          return createElement(IssuablesListApp, { props });
        },
      });
    });
  }
}
