import { createLocalVue, shallowMount } from '@vue/test-utils';
import Vuex from 'vuex';
import PanelType from 'ee_else_ce/monitoring/components/panel_type.vue';
import { TEST_HOST } from 'helpers/test_constants';
import Embed from '~/monitoring/components/embed.vue';
import { groups, initialState, metricsData, metricsWithData } from './mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('Embed', () => {
  let wrapper;
  let store;
  let actions;
  let metricsWithDataGetter;

  function mountComponent(options = {}) {
    wrapper = shallowMount(Embed, {
      localVue,
      store,
      propsData: {
        dashboardUrl: TEST_HOST,
      },
    });
  }

  beforeEach(() => {
    actions = {
      setFeatureFlags: jest.fn(),
      setShowErrorBanner: jest.fn(),
      setEndpoints: jest.fn(),
      setTimeRange: jest.fn(),
      fetchMetricsData: jest.fn(),
    };

    metricsWithDataGetter = jest.fn();

    store = new Vuex.Store({
      modules: {
        monitoringDashboard: {
          namespaced: true,
          actions,
          getters: {
            metricsWithData: () => metricsWithDataGetter,
          },
          state: initialState,
        },
      },
    });
  });

  afterEach(() => {
    metricsWithDataGetter.mockClear();
    if (wrapper) {
      wrapper.destroy();
    }
  });

  describe('no metrics are available yet', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('shows an empty state when no metrics are present', () => {
      expect(wrapper.find('.metrics-embed').exists()).toBe(true);
      expect(wrapper.find(PanelType).exists()).toBe(false);
    });
  });

  describe('metrics are available', () => {
    beforeEach(() => {
      store.state.monitoringDashboard.dashboard.panel_groups = groups;
      store.state.monitoringDashboard.dashboard.panel_groups[0].panels = metricsData;

      metricsWithDataGetter.mockReturnValue(metricsWithData);

      mountComponent();
    });

    it('calls actions to fetch data', () => {
      const expectedState = expect.any(Object);
      const expectedTimeRangePayload = expect.objectContaining({
        start: expect.any(String),
        end: expect.any(String),
      });

      expect(actions.setTimeRange).toHaveBeenCalled();
      expect(actions.setTimeRange).toHaveBeenCalledWith(
        expectedState,
        expectedTimeRangePayload,
        undefined,
      );

      expect(actions.fetchMetricsData).toHaveBeenCalled();
      expect(actions.fetchMetricsData).toHaveBeenCalledWith(expectedState, undefined, undefined);
    });

    it('shows a chart when metrics are present', () => {
      expect(wrapper.find('.metrics-embed').exists()).toBe(true);
      expect(wrapper.find(PanelType).exists()).toBe(true);
      expect(wrapper.findAll(PanelType).length).toBe(2);
    });

    it('includes groupId with dashboardUrl', () => {
      expect(wrapper.find(PanelType).props('groupId')).toBe(TEST_HOST);
    });
  });
});
