import * as types from './mutation_types';

export default {
  [types.LOAD_CONTENT](state) {
    state.isLoadingContent = true;
    state.isContentLoaded = false;
  },
  [types.RECEIVE_CONTENT_SUCCESS](state, { content }) {
    state.isLoadingContent = false;
    state.isContentLoaded = true;
    state.content = content;
  },
  [types.RECEIVE_CONTENT_ERROR](state) {
    state.isLoadingContent = false;
    state.isContentLoaded = false;
  },
};
