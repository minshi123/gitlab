import * as types from './mutation_types';

export const setInitialState = ({ commit }, props) => commit(types.SET_INITIAL_STATE, props);

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
