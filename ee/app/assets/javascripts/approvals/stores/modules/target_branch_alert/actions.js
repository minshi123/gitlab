import * as types from './mutations_types';

// export const closingSomething = ({ commit }) => {
//   console.log('click');
//   commit(types.CLOSE_TARGET_BRANCH_ALERT);
// };

export const closeAlert = ({ commit }) => {
  // dispatch('closingSomething');

  // This doesn't work
  commit(types.CLOSE_TARGET_BRANCH_ALERT);
  return undefined;
};

export default () => {};
