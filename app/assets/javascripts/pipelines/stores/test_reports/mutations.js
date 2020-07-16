import * as types from './mutation_types';

export default {
  [types.SET_REPORTS](state, testReports) {
    Object.assign(state, { testReports, hasFullReport: true });
  },

  [types.SET_SUITE](state, { suite = {}, index = null }) {
    state.testReports.test_suites[index] = { ...suite, hasFullSuite: true };
    // const testSuites = Object.assign([], state.testReports.test_suites, { [index]: { ...suite, hasFullSuite: true } });
    // console.log('HERE', testSuites);
    // console.log(state.testReports);
    // Object.assign(state.testReports, { test_suites: testSuites });
    // Object.assign(state, { testReports: { ...state.testReports, test_suites: testSuites } });
  },

  [types.SET_SELECTED_SUITE_INDEX](state, selectedSuiteIndex) {
    Object.assign(state, { selectedSuiteIndex });
  },

  [types.SET_SUMMARY](state, summary) {
    Object.assign(state, { testReports: { ...state.testReports, ...summary } });
  },

  [types.TOGGLE_LOADING](state) {
    Object.assign(state, { isLoading: !state.isLoading });
  },
};
