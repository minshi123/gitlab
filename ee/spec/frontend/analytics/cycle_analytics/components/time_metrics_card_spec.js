import { mount } from '@vue/test-utils';
import TimeMetricsCard from 'ee/analytics/cycle_analytics/components/time_metrics_card.vue';
import { group } from '../mock_data';

describe('TimeMetricsCard', () => {
  const { full_path: groupPath } = group;
  let wrapper;

  const createComponent = () => {
    return mount(TimeMetricsCard, {
      propsData: {
        groupPath,
      },
    });
  };

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches the snapshot', () => {
    expect(wrapper.element).toMatchSnapshot();
  });
});
