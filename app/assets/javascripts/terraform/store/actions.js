import Visibility from 'visibilityjs';
import * as types from './mutation_types';

export const setEndpoint = ({ commit }, endpoint) => commit(types.SET_ENDPOINT, endpoint);

export const fetchPlans = () => {
  console.log('fetch time!! I need a real url!!')
};
