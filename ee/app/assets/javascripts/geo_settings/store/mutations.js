import * as types from './mutation_types';

export default {
  [types.SET_TIMEOUT](state, timeout) {
    state.timeout = timeout;
  },
  [types.SET_ALLOWED_IP](state, allowedIp) {
    state.allowedIp = allowedIp;
  },
  [types.REQUEST_GEO_SETTINGS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_GEO_SETTINGS_SUCCESS](state, { timeout, allowedIp }) {
    state.isLoading = false;
    state.timeout = timeout;
    state.allowedIp = allowedIp;
  },
  [types.RECEIVE_GEO_SETTINGS_ERROR](state) {
    state.isLoading = false;
    state.timeout = null;
    state.allowedIp = null;
  },
};
