import Poll from '~/lib/utils/poll';
import Visibility from 'visibilityjs';
import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';
import { __ } from '~/locale';
import * as types from './mutation_types';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const fetchPlans = ({ state, commit }) => {
  const poll = new Poll({
    resource: {
      fetchPlans: endpoint => axios.get(endpoint),
    },
    data: state.endpoint,
    method: 'fetchPlans',
    successCallback: ({ data }) => {
      console.log('successCallback')
      console.log(data)
    },
    errorCallback: () => flash(__('An error occurred while loading terraform plans')),
  })

  if (!Visibility.hidden()) {
    poll.makeRequest();
  }

  Visibility.change(() => {
    if (!Visibility.hidden()) {
      poll.restart();
    } else {
      poll.stop();
    }
  });
};
