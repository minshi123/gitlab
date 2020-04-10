import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import FirstClassInstanceDashboard from 'ee/security_dashboard/components/first_class_instance_security_dashboard.vue';
import FirstClassInstanceVulnerabilities from 'ee/security_dashboard/components/first_class_instance_security_dashboard_vulnerabilities.vue';
import ProjectManager from 'ee/security_dashboard/components/project_manager.vue';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('First Class Group Dashboard Component', () => {
  let store;
  let wrapper;

  const dashboardDocumentation = 'dashboard-documentation';
  const emptyStateSvgPath = 'empty-state-path';
  const projectAddEndpoint = 'projectAddEndpoint';
  const projectListEndpoint = 'projectListEndpoint';

  const findInstanceVulnerabilities = () => wrapper.find(FirstClassInstanceVulnerabilities);

  const defaultData = {
    showProjectSelector: false,
  };

  const createWrapper = ({ data = defaultData }) => {
    store = new Vuex.Store({
      modules: {
        projectSelector: {
          namespaced: true,
          actions: {
            fetchProjects() {},
            setProjectEndpoints() {},
          },
          state: {
            projects: [],
          },
        },
      },
    });

    return shallowMount(FirstClassInstanceDashboard, {
      localVue,
      store,
      propsData: {
        dashboardDocumentation,
        emptyStateSvgPath,
        projectAddEndpoint,
        projectListEndpoint,
      },
      data: () => data,
      stubs: { SecurityDashboardLayout },
    });
  };

  const findProjectSelectorToggleButton = () => wrapper.find('.js-project-selector-toggle');

  beforeEach(() => {
    wrapper = createWrapper({});
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('should render correctly on load', () => {
    expect(wrapper.find('.page-title').text()).toBe('Security Dashboard');
    expect(findInstanceVulnerabilities().props()).toEqual({
      dashboardDocumentation,
      emptyStateSvgPath,
    });
    expect(findProjectSelectorToggleButton().exists()).toBe(true);
    expect(wrapper.contains(ProjectManager)).toBe(false);
  });

  it('should render correctly during project selection', () => {
    wrapper = createWrapper({ data: { showProjectSelector: true } });
    expect(findProjectSelectorToggleButton().exists()).toBe(true);
    expect(findInstanceVulnerabilities().exists()).toBe(false);
    expect(wrapper.contains(ProjectManager)).toBe(true);
  });

  describe('methods', () => {
    describe('toggleProjectSelector', () => {
      beforeEach(() => {
        wrapper = createWrapper({});
      });

      it('should toggle the showProjectSelector from false to true', () => {
        wrapper.vm.toggleProjectSelector();
        expect(wrapper.vm.showProjectSelector).toBe(true);

      })

      it('should toggle the showProjectSelector from true to false', () => {
        wrapper = createWrapper({ data: { showProjectSelector: true } });
        wrapper.vm.toggleProjectSelector();
        expect(wrapper.vm.showProjectSelector).toBe(false);
      })
    })
  });

  describe('computed', () => {
    describe('toggleButtonProps', () => {
      beforeEach(() => {
        wrapper = createWrapper({});
      });

      it('returns the appropriate message when showProjectSelector is false', () => {
        expect(wrapper.vm.toggleButtonProps.text).toBe('Edit dashboard');
      });

      it('returns the appropriate message when showProjectSelector is true', () => {
        wrapper = createWrapper({ data: { showProjectSelector: true } });
        expect(wrapper.vm.toggleButtonProps.text).toBe('Return to dashboard');
      });
    });
  });
});
