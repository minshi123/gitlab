import * as types from './mutation_types';

export default {
  [types.SET_INITIAL_DATA](state, { commitsPath }) {
    state.commitsPath = commitsPath;
  },
};
