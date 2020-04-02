import * as types from './mutation_types';

export default {
  [types.SET_ENDPOINT](state, endpoint) {
    state.endpoint = String(endpoint);
  },
  [types.UPDATE_LOADING](state, loading) {
    state.loading = Boolean(loading);
  },
  [types.UPDATE_NUMBER_TO_ADD](state, createValue) {
    state.numberToAdd = Number(createValue);
  },
  [types.UPDATE_NUMBER_TO_CHANGE](state, changeValue) {
    state.numberToChange = Number(changeValue);
  },
  [types.UPDATE_NUMBER_TO_DELETE](state, deleteValue) {
    state.numberToDelete = Number(deleteValue);
  },
}
