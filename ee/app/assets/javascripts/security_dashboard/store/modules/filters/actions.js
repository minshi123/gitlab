import Tracking from '~/tracking';
import { getParameterValues } from '~/lib/utils/url_utility';
import * as types from './mutation_types';
import { ALL } from './constants';
import { hasValidSelection } from './utils';
import axios from '~/lib/utils/axios_utils';

import AxiosMockAdapter from 'axios-mock-adapter';

export const setFilter = ({ commit }, { filterId, optionId, lazy = false }) => {
  commit(types.SET_FILTER, { filterId, optionId, lazy });

  Tracking.event(document.body.dataset.page, 'set_filter', {
    label: filterId,
    value: optionId,
  });
};

export const setFilterOptions = ({ commit, state }, { filterId, options, lazy = false }) => {
  commit(types.SET_FILTER_OPTIONS, { filterId, options });

  const { selection } = state.filters.find(({ id }) => id === filterId);
  if (!hasValidSelection({ selection, options })) {
    commit(types.SET_FILTER, { filterId, optionId: ALL, lazy });
  }
};

export const setAllFilters = ({ commit }, payload) => {
  commit(types.SET_ALL_FILTERS, payload);
};

export const lockFilter = ({ commit }, payload) => {
  commit(types.SET_FILTER, payload);
  commit(types.HIDE_FILTER, payload);
};

export const setHideDismissedToggleInitialState = ({ commit }) => {
  const [urlParam] = getParameterValues('scope');
  const showDismissed = urlParam === 'all';
  commit(types.SET_TOGGLE_VALUE, { key: 'hideDismissed', value: !showDismissed });
};

export const setToggleValue = ({ commit }, { key, value }) => {
  commit(types.SET_TOGGLE_VALUE, { key, value });

  Tracking.event(document.body.dataset.page, 'set_toggle', {
    label: key,
    value,
  });
};

export const fetchFiltersData = ({ dispatch }, endpoint) => {
  const axiosMock = new AxiosMockAdapter(axios, { delayResponse: 1000 });
  axiosMock.onGet('/filters/data').reply(200, {
    report_type: [
      {
        id: 'container_scanning',
        vulnerability_count: 12,
      },
      {
        id: 'dast',
        vulnerability_count: 835,
      },
      {
        id: 'dependency_scanning',
        vulnerability_count: 538,
      },
      {
        id: 'sast',
        vulnerability_count: 358,
      },
    ],
  });
  dispatch('requestFiltersData');
  axios
    .get(endpoint)
    .then(response => {
      dispatch('receiveFiltersDataSuccess', response);
    })
    .catch(() => {
      dispatch('receiveFiltersDataError');
    });
};

export const requestFiltersData = ({ commit }) => {
  commit(types.REQUEST_FILTERS_DATA);
};

export const receiveFiltersDataSuccess = ({ commit }, { data }) => {
  console.log('receiveFiltersDataSuccess', data);

  commit(types.RECEIVE_FILTERS_DATA_SUCCESS, data);
};

export const receiveFiltersDataError = ({ commit }) => {
  commit(types.RECEIVE_FILTERS_DATA_ERROR);
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
