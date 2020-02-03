import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import createFlash from '~/flash';
import { queryToObject, redirectTo, removeParams, mergeUrlParams } from '~/lib/utils/url_utility';
import axios from '~/lib/utils/axios_utils';
import { mockProjectDir } from '../mock_data';

import Dashboard from '~/monitoring/components/dashboard.vue';
import { createStore } from '~/monitoring/stores';
import { defaultTimeRange } from '~/monitoring/constants';
import { propsData } from '../init_utils';

jest.mock('~/flash');
jest.mock('~/lib/utils/url_utility');

describe('dashboard invalid url parameters', () => {
  let store;
  let wrapper;
  let mock;

  const actionMocks = {
    setTimeRange: jest.fn(),
    fetchData: jest.fn(),
  };

  const createMountedWrapper = (props = { hasMetrics: true }, options = {}) => {
    wrapper = mount(Dashboard, {
      propsData: { ...propsData, ...props },
      store,
      stubs: ['graph-group', 'panel-type'],
      methods: {
        ...actionMocks,
      },
      ...options,
    });
  };

  const findDateTimePicker = () => wrapper.find({ ref: 'dateTimePicker' });

  beforeEach(() => {
    store = createStore();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
    mock.restore();

    actionMocks.setTimeRange.mockReset();
    actionMocks.fetchData.mockReset();

    queryToObject.mockReset();
  });

  it('passes default url parameters to the time range picker', () => {
    queryToObject.mockReturnValue({});

    createMountedWrapper();

    return wrapper.vm.$nextTick().then(() => {
      expect(findDateTimePicker().props('value')).toEqual(defaultTimeRange);

      expect(actionMocks.setTimeRange).toHaveBeenCalledTimes(1);
      expect(actionMocks.setTimeRange).toHaveBeenCalledWith(defaultTimeRange);

      expect(actionMocks.fetchData).toHaveBeenCalledTimes(1);
    });
  });

  it('passes a fixed time range in the URL to the time range picker', () => {
    const params = {
      start: '2019-01-01T00:00:00.000Z',
      end: '2019-01-10T00:00:00.000Z',
    };

    queryToObject.mockReturnValue(params);

    createMountedWrapper();

    return wrapper.vm.$nextTick().then(() => {
      expect(findDateTimePicker().props('value')).toEqual(params);

      expect(actionMocks.setTimeRange).toHaveBeenCalledTimes(1);
      expect(actionMocks.setTimeRange).toHaveBeenCalledWith(params);

      expect(actionMocks.fetchData).toHaveBeenCalledTimes(1);
    });
  });

  it('passes a rolling time range in the URL to the time range picker', () => {
    queryToObject.mockReturnValue({
      duration_seconds: '120',
    });

    createMountedWrapper();

    return wrapper.vm.$nextTick().then(() => {
      const expectedTimeRange = {
        duration: { seconds: 60 * 2 },
      };

      expect(findDateTimePicker().props('value')).toMatchObject(expectedTimeRange);

      expect(actionMocks.setTimeRange).toHaveBeenCalledTimes(1);
      expect(actionMocks.setTimeRange).toHaveBeenCalledWith(expectedTimeRange);

      expect(actionMocks.fetchData).toHaveBeenCalledTimes(1);
    });
  });

  it('shows an error message and loads a default time range if invalid url parameters are passed', () => {
    queryToObject.mockReturnValue({
      start: '<script>alert("XSS")</script>',
      end: '<script>alert("XSS")</script>',
    });

    createMountedWrapper();

    return wrapper.vm.$nextTick().then(() => {
      expect(createFlash).toHaveBeenCalled();

      expect(findDateTimePicker().props('value')).toEqual(defaultTimeRange);

      expect(actionMocks.setTimeRange).toHaveBeenCalledTimes(1);
      expect(actionMocks.setTimeRange).toHaveBeenCalledWith(defaultTimeRange);

      expect(actionMocks.fetchData).toHaveBeenCalledTimes(1);
    });
  });

  it('redirects to different time range', () => {
    const toUrl = `${mockProjectDir}/-/environments/1/metrics`;
    removeParams.mockReturnValueOnce(toUrl);

    createMountedWrapper();

    return wrapper.vm.$nextTick().then(() => {
      findDateTimePicker().vm.$emit('input', {
        duration: { seconds: 120 },
      });

      // redirect to plus + new parameters
      expect(mergeUrlParams).toHaveBeenCalledWith({ duration_seconds: '120' }, toUrl);
      expect(redirectTo).toHaveBeenCalledTimes(1);
    });
  });
});
