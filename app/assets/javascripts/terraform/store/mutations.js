import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = endpoint;
  },
  [types.UPDATE_NUMBER_TO_ADD](state, createValue) {
    state.numberToAdd = Number(createValue) || null;
  },
}
