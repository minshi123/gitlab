import Vue from 'vue';
import Vuex from 'vuex';
import TargetBranchAlertApp from './components/target_branch_alert/app.vue';
import createStore from './stores/modules/target_branch_alert';
// import createStore from './stores';
// import targetBranchAlertModule from './stores/modules/target_branch_alert';

Vue.use(Vuex);

export default function mountTargetBranchAlert(el) {
  if (!el) {
    return null;
  }

  // const store = createStore(targetBranchAlertModule(), {
  //   prefix: 'target-branch-alert',
  //   pear: 'hello',
  // });

  const store = createStore();

  return new Vue({
    el,
    store,
    render(h) {
      return h(TargetBranchAlertApp);
    },
  });
}
