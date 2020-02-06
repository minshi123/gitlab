import * as types from './mutation_types';

export default {
  [types.SET_INITIAL_STATE](state, props) {
    Object.assign(state, { ...props });
  },
};
