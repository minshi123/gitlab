import Api from '~/api';
import createFlash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

// Fetch Geo Settings
export const requestGeoSettings = ({ commit }) => commit(types.REQUEST_GEO_SETTINGS);
export const receiveGeoSettingsSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_GEO_SETTINGS_SUCCESS, data);
export const receiveGeoSettingsError = ({ commit }) => {
  createFlash(__('There was an error fetching the Geo Settings'));
  commit(types.RECEIVE_GEO_SETTINGS_ERROR);
};

export const fetchGeoSettings = ({ dispatch }) => {
  dispatch('requestGeoSettings');
  Api.getApplicationSettings()
    .then(({ data }) => {
      dispatch('receiveGeoSettingsSuccess', {
        timeout: data.geo_status_timeout,
        allowedIp: data.geo_node_allowed_ips,
      });
    })
    .catch(() => {
      dispatch('receiveGeoSettingsError');
    });
};

// Updating Fields
export const setTimeout = ({ commit }, timeout) => {
  commit(types.SET_TIMEOUT, timeout);
};

export const setAllowedIp = ({ commit }, allowedIp) => {
  commit(types.SET_ALLOWED_IP, allowedIp);
};
