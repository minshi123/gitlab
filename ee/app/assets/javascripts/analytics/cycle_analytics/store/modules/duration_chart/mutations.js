import * as types from './mutation_types';

export default {
  [types.UPDATE_SELECTED_DURATION_CHART_STAGES](
    state,
    { updatedDurationStageData, updatedDurationStageMedianData },
  ) {
    state.durationData = updatedDurationStageData;
    state.durationMedianData = updatedDurationStageMedianData;
  },
  [types.REQUEST_DURATION_DATA](state) {
    state.isLoadingDurationChart = true;
  },
  [types.RECEIVE_DURATION_DATA_SUCCESS](state, data) {
    state.durationData = data;
    state.isLoadingDurationChart = false;
  },
  [types.RECEIVE_DURATION_DATA_ERROR](state) {
    state.durationData = [];
    state.isLoadingDurationChart = false;
  },
  [types.REQUEST_DURATION_MEDIAN_DATA](state) {
    state.isLoadingDurationChartMedianData = true;
  },
  [types.RECEIVE_DURATION_MEDIAN_DATA_SUCCESS](state, data) {
    state.durationMedianData = data;
    state.isLoadingDurationChartMedianData = false;
  },
  [types.RECEIVE_DURATION_MEDIAN_DATA_ERROR](state) {
    state.durationMedianData = [];
    state.isLoadingDurationChartMedianData = false;
  },
};
