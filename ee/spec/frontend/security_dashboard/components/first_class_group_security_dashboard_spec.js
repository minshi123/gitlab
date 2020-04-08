import { shallowMount } from '@vue/test-utils';
import FirstClassGroupDashboard from 'ee/security_dashboard/components/first_class_group_security_dashboard.vue';
import FirstClassGroupVulnerabilities from 'ee/security_dashboard/components/first_class_group_security_dashboard_vulnerabilities.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';

describe('First Class Group Dashboard Component', () => {
  let wrapper;

  const dashboardDocumentation = 'dashboard-documentation';
  const emptyStateSvgPath = 'empty-state-path';
  const groupFullPath = 'group-full-path';

  const findGroupVulnerabilities = () => wrapper.find(FirstClassGroupVulnerabilities);
  const findFilters = () => wrapper.find(Filters);

  const createWrapper = () => {
    return shallowMount(FirstClassGroupDashboard, {
      propsData: {
        dashboardDocumentation,
        emptyStateSvgPath,
        groupFullPath,
      },
      stubs: {
        SecurityDashboardLayout,
      },
    });
  };

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('should render correctly', () => {
    expect(findGroupVulnerabilities().props()).toEqual({
      dashboardDocumentation,
      emptyStateSvgPath,
      groupFullPath,
      filters: {},
    });
  });

  it('has filters', () => {
    expect(findFilters().exists()).toBe(true);
  });

  it('it responds to the filterChange event', () => {
    const filters = { severity: 'critical' };
    findFilters().vm.$listeners.filterChange(filters);
    return wrapper.vm.$nextTick(() => {
      expect(wrapper.vm.filters).toEqual(filters);
      expect(findGroupVulnerabilities().props('filters')).toEqual(filters);
    });
  });
});
