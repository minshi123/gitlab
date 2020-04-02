import { mount } from '@vue/test-utils';
import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';
import RecentActivityCard from 'ee/analytics/cycle_analytics/components/recent_activity_card.vue';
import MetricCard from 'ee/analytics/shared/components/metric_card.vue';
import waitForPromises from 'helpers/wait_for_promises';
import { endpoints, group, recentActivityData } from '../mock_data';

describe('RecentActivityCard', () => {
  const { full_path: groupPath } = group;
  let wrapper;
  let mock;

  const findMetricCard = () => wrapper.find(MetricCard);

  const createComponent = (additionalParams = {}) => {
    return mount(RecentActivityCard, {
      propsData: {
        groupPath,
        additionalParams,
      },
    });
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
    mock.onGet(endpoints.recentActivityData).reply(200, recentActivityData);

    wrapper = createComponent();

    return wrapper.vm.$nextTick().then(waitForPromises);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });

  it('fetches the recent activity data', () => {
    const reqs = mock.history.get;
    expect(reqs.length).toEqual(1);
    expect(reqs[0].url).toEqual('/-/analytics/value_stream_analytics/summary');
  });
  it('renders the returned metrics', () => {
    recentActivityData.forEach(({ title, value }) => {
      expect(findMetricCard().html()).toContain(title);
      expect(findMetricCard().html()).toContain(value > 0 ? value : '-');
    });
  });

  it('passes the metrics array to the metric card', () => {
    expect(findMetricCard().props('metrics')).toEqual([
      { key: 'new-issues', label: 'New Issues', value: 3 },
      { key: 'deploys', label: 'Deploys', value: '-' },
    ]);
  });

  describe('with additional params', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.recentActivityData).reply(200, recentActivityData);

      wrapper = createComponent({
        'project_ids[]': [1],
        created_after: '2020-01-01',
        created_before: '2020-02-01',
      });

      return wrapper.vm.$nextTick().then(waitForPromises);
    });

    it('fetches the recent activity data', () => {
      const reqs = mock.history.get;
      expect(reqs.length).toEqual(1);
      expect(reqs[0].url).toEqual('/-/analytics/value_stream_analytics/summary');
    });

    it('sends additional parameters as query paremeters', () => {
      const reqs = mock.history.get;
      expect(reqs[0].params).toEqual({
        group_id: groupPath,
        'project_ids[]': [1],
        created_after: '2020-01-01',
        created_before: '2020-02-01',
      });
    });
  });
});
