import * as types from './mutations_types';

export default {
  [types.CLOSE_TARGET_BRANCH_ALERT](state) {
    console.log(state);
    state.showAlert = false;
  },
  [types.OPEN_TARGET_BRANCH_ALERT](state) {
    state.showAlert = true;
  },
  [types.SHOW_TARGET_BRANCH_ALERT](state, isShowing) {
    state.showAlert = isShowing;
  },
};
