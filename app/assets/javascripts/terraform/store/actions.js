import Visibility from 'visibilityjs';
import * as types from './mutation_types';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const fetchPlans = ({ state, commit }) => {
  console.log('fetch time!! With my  new endpoint')
  console.log(state.endpoint)
};
