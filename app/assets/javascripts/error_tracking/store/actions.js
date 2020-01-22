import service from './../services';
import * as types from './mutation_types';
import createFlash from '~/flash';
import { visitUrl } from '~/lib/utils/url_utility';
import { __ } from '~/locale';

export function setStatus({ commit }, status) {
  commit(types.SET_ERROR_STATUS, status.toLowerCase());
}

export function setUpdatingResolveStatus({ commit }, updating) {
  commit(types.SET_UPDATING_RESOLVE_STATUS, updating);
}

export function setUpdatingIgnoreStatus({ commit }, updating) {
  commit(types.SET_UPDATING_IGNORE_STATUS, updating);
}

export function updateStatus({ commit }, { endpoint, redirectUrl, status }) {
  return service
    .updateErrorStatus(endpoint, status)
    .then(resp => {
      commit(types.SET_ERROR_STATUS, status);
      if (redirectUrl) visitUrl(redirectUrl);

      return resp.data.result;
    })
    .catch(() => createFlash(__('Failed to update issue status')))
    .finally(() => {
      commit(types.SET_UPDATING_RESOLVE_STATUS, false);
      commit(types.SET_UPDATING_IGNORE_STATUS, false);
    });
}

export default () => {
};
