import Poll from '~/lib/utils/poll';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

// Nodes are part of a reactive cache which may take mutliple requests to finish querying
const nodesQueried = clusters => {
  return clusters.length === clusters.filter(cluster => cluster.nodes != null).length;
};

export const fetchClusters = ({ state, commit }) => {
  const poll = new Poll({
    resource: {
      fetchClusters: endpoint => axios.get(endpoint),
    },
    data: state.endpoint,
    method: 'fetchClusters',
    successCallback: ({ data }) => {
      if (data.clusters) {
        commit(types.SET_CLUSTERS_DATA, data);
        commit(types.SET_LOADING_STATE, false);

        if (nodesQueried(data.clusters)) {
          poll.stop();
        }
      }
    },
    errorCallback: () => flash(__('An error occurred while loading clusters')),
  });

  poll.makeRequest();
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
