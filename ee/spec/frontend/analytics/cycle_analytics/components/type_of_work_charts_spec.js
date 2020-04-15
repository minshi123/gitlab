import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon } from '@gitlab/ui';
import TypeOfWorkCharts from 'ee/analytics/cycle_analytics/components/type_of_work_charts.vue';
import TasksByTypeChart from 'ee/analytics/cycle_analytics/components/tasks_by_type/tasks_by_type_chart.vue';
import TasksByTypeFilters from 'ee/analytics/cycle_analytics/components/tasks_by_type/tasks_by_type_filters.vue';
import {
  TASKS_BY_TYPE_SUBJECT_ISSUE,
  TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
  TASKS_BY_TYPE_FILTERS,
} from 'ee/analytics/cycle_analytics/constants';

const selectedTasksByTypeFilters = {
  selectedGroup: {
    id: 22,
    name: 'Gitlab Org',
    fullName: 'Gitlab Org',
    fullPath: 'gitlab-org',
  },
  selectedProjectIds: [],
  startDate: new Date('2019-12-11'),
  endDate: new Date('2020-01-10'),
  subject: TASKS_BY_TYPE_SUBJECT_ISSUE,
  selectedLabelIds: [1, 2, 3],
};

const seriesNames = ['Cool label', 'Normal label'];
const data = [[0, 1, 2], [5, 2, 3], [2, 4, 1]];
const groupBy = ['Group 1', 'Group 2', 'Group 3'];

describe('TypeOfWorkCharts', () => {
  function createComponent({ props = {} }) {
    return shallowMount(TypeOfWorkCharts, {
      propsData: {
        isLoading: false,
        tasksByTypeChartData: { data, groupBy, seriesNames },
        selectedTasksByTypeFilters,
        ...props,
      },
    });
  }

  let wrapper = null;

  const findSubjectFilters = _wrapper => _wrapper.find(TasksByTypeFilters);
  const findTasksByTypeChart = _wrapper => _wrapper.find(TasksByTypeChart);
  const findLoader = _wrapper => _wrapper.find(GlLoadingIcon);

  beforeEach(() => {
    wrapper = createComponent({});
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with data', () => {
    it('renders the task by type chart', () => {
      expect(findTasksByTypeChart(wrapper).exists()).toBe(true);
    });

    it('does not render the loading icon', () => {
      expect(findLoader(wrapper).exists()).toBe(false);
    });

    it('emits the `updateFilter` event when a subject filter is clicked', () => {
      expect(wrapper.emitted('updateFilter')).toBeUndefined();

      findSubjectFilters(wrapper).trigger('updateFilter');

      return wrapper.vm.$nextTick(() => {
        expect(wrapper.emitted('updateFilter')).toBeDefined();
        expect(wrapper.emitted('updateFilter')[0]).toEqual([
          {
            filter: TASKS_BY_TYPE_FILTERS.SUBJECT,
            value: TASKS_BY_TYPE_SUBJECT_MERGE_REQUEST,
          },
        ]);
      });
    });
  });

  describe('while loading', () => {
    beforeEach(() => {
      wrapper = createComponent({ props: { isLoading: true } });
    });

    it('renders loading icon', () => {
      expect(findLoader(wrapper).exists()).toBe(true);
    });
  });
});
