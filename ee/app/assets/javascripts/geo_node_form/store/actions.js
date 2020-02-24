import PublicApi from '~/api';
import Api from 'ee/api';
import createFlash from '~/flash';
import { visitUrl } from '~/lib/utils/url_utility';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const requestSyncNamespaces = ({ commit }) => commit(types.REQUEST_SYNC_NAMESPACES);
export const receiveSyncNamespacesSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_SYNC_NAMESPACES_SUCCESS, data);
export const receiveSyncNamespacesError = ({ commit }) => {
  createFlash(__("There was an error fetching the Node's Groups"));
  commit(types.RECEIVE_SYNC_NAMESPACES_ERROR);
};

export const fetchSyncNamespaces = ({ dispatch }, search) => {
  dispatch('requestSyncNamespaces');

  PublicApi.groups(search)
    .then(res => {
      dispatch('receiveSyncNamespacesSuccess', res);
    })
    .catch(() => {
      dispatch('receiveSyncNamespacesError');
    });
};

export const requestCreateGeoNode = ({ commit }) => commit(types.REQUEST_CREATE_GEO_NODE);
export const receiveCreateGeoNodeSuccess = ({ commit }) => {
  commit(types.RECEIVE_CREATE_GEO_NODE_SUCCESS);
  visitUrl('/admin/geo/nodes');
};
export const receiveCreateGeoNodeError = ({ commit }) => {
  createFlash(__(`There was an error creating this Geo Node`));
  commit(types.RECEIVE_CREATE_GEO_NODE_ERROR);
};

export const createGeoNode = ({ dispatch }, node) => {
  dispatch('requestCreateGeoNode');
  const sanitizedNode = convertObjectPropsToSnakeCase(node);

  Api.createGeoNode(sanitizedNode)
    .then(() => dispatch('receiveCreateGeoNodeSuccess'))
    .catch(() => {
      dispatch('receiveCreateGeoNodeError');
    });
};

export const requestUpdateGeoNode = ({ commit }) => commit(types.REQUEST_UPDATE_GEO_NODE);
export const receiveUpdateGeoNodeSuccess = ({ commit }) => {
  commit(types.RECEIVE_UPDATE_GEO_NODE_SUCCESS);
  visitUrl('/admin/geo/nodes');
};
export const receiveUpdateGeoNodeError = ({ commit }) => {
  createFlash(__(`There was an error updating this Geo Node`));
  commit(types.RECEIVE_UPDATE_GEO_NODE_ERROR);
};

export const updateGeoNode = ({ dispatch }, node) => {
  dispatch('requestUpdateGeoNode');
  const sanitizedNode = convertObjectPropsToSnakeCase(node);

  Api.updateGeoNode(sanitizedNode)
    .then(() => dispatch('receiveUpdateGeoNodeSuccess'))
    .catch(() => {
      dispatch('receiveUpdateGeoNodeError');
    });
};
