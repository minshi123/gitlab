import * as types from './mutation_types';

export default {
  setInitialData({ commit }, data) {
    commit(types.SET_INITIAL_DATA, data);
  },
};
