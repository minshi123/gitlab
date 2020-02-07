import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { humanize } from '~/lib/utils/text_utility';

export const requestConfig = ({ commit }) => commit(types.REQUEST_CONFIG);
export const receiveConfigSuccess = ({ commit }, data) =>
  commit(types.RECEIVE_CONFIG_SUCCESS, data);
export const receiveConfigError = ({ commit }, errorMessage) => {
  const error = errorMessage || __('Unknown Error');
  const message = `${__('There was an error fetching configuration for charts')}: ${error}`;
  createFlash(message);
  commit(types.RECEIVE_CONFIG_ERROR);
};

export const fetchConfigData = ({ dispatch }, endpoint) => {
  dispatch('requestConfig');

  return axios
    .get(endpoint)
    .then(({ data }) => {
      if (data) {
        dispatch('receiveConfigSuccess', data);
      } else {
        dispatch('receiveConfigError');
      }
    })
    .catch(error => {
      dispatch('receiveConfigError', error.response.data.message);
    });
};

export const receiveChartDataSuccess = ({ commit }, { chart, data }) =>
  commit(types.RECEIVE_CHART_SUCCESS, { chart, data });
export const receiveChartDataError = ({ commit }, { chart, error }) =>
  commit(types.RECEIVE_CHART_ERROR, { chart, error });

const transformChartDataForGlCharts = ({ type, query }, { labels, datasets }) => {
  const formattedData = {
    // Appending 's' to the end to pluralise, our accepted values don't support other variants https://docs.gitlab.com/ee/user/project/insights/#queryissuable_type
    xAxisTitle: `${humanize(query.group_by)}s`,
    yAxisTitle: `${humanize(query.issuable_type)}s`,
    labels,
    datasets: [],
  };

  switch (type) {
    case 'stacked-bar':
      formattedData.datasets = datasets.map(dataset => dataset.data);
      break;
    case 'line':
      for (let i = 0; i < datasets.length; i += 1) {
        formattedData.datasets.push({
          name: datasets[i].label,
          data: labels.map((label, j) => [label, datasets[0].data[j]]),
        });
      }

      break;
    default:
      formattedData.datasets = { all: labels.map((label, i) => [label, datasets[0].data[i]]) };
  }

  return formattedData;
};

export const fetchChartData = ({ dispatch }, { endpoint, chart }) =>
  axios
    .post(endpoint, chart)
    .then(({ data }) =>
      dispatch('receiveChartDataSuccess', {
        chart,
        data: transformChartDataForGlCharts(chart, data),
      }),
    )
    .catch(error => {
      let message = `${__('There was an error gathering the chart data')}`;

      if (error.response.data && error.response.data.message) {
        message += `: ${error.response.data.message}`;
      }
      createFlash(message);
      dispatch('receiveChartDataError', { chart, error: message });
    });

export const setActiveTab = ({ commit, state }, key) => {
  const { configData } = state;

  if (configData) {
    const page = configData[key];

    if (page) {
      commit(types.SET_ACTIVE_TAB, key);
      commit(types.SET_ACTIVE_PAGE, page);
    } else {
      createFlash(__('The specified tab is invalid, please select another'));
    }
  }
};

export const initChartData = ({ commit }, store) => commit(types.INIT_CHART_DATA, store);
export const setPageLoading = ({ commit }, pageLoading) =>
  commit(types.SET_PAGE_LOADING, pageLoading);

export default () => {};
