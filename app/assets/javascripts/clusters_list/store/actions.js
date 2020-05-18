import Poll from '~/lib/utils/poll';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { __ } from '~/locale';
import { MAX_REQUESTS } from '../constants';
import * as types from './mutation_types';

const allNodesPresent = clusters => {
  return clusters.length === clusters.filter(cluster => cluster.nodes != null).length;
};

export const fetchClusters = ({ state, commit }) => {
  let retryCount = 0;

  const poll = new Poll({
    resource: {
      fetchClusters: endpoint => axios.get(endpoint),
    },
    data: state.endpoint,
    method: 'fetchClusters',
    successCallback: ({ data }) => {
      retryCount += 1;

      if (data.clusters) {
        commit(types.SET_CLUSTERS_DATA, data);
        commit(types.SET_LOADING_STATE, false);

        if (allNodesPresent(data.clusters) || retryCount > MAX_REQUESTS) {
          poll.stop();
        }
      }
    },
    errorCallback: () => {
      commit(types.SET_LOADING_STATE, false);
      flash(__('An error occurred while loading clusters'));
      poll.stop();
    },
  });

  poll.makeRequest();
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
