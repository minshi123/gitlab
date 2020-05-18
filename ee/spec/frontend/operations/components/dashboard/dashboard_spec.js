import Vuex from 'vuex';
import { shallowMount, createLocalVue } from '@vue/test-utils';
import { GlDashboardSkeleton, GlEmptyState } from '@gitlab/ui';
import Dashboard from 'ee/operations/components/dashboard/dashboard.vue';
import Project from 'ee/operations/components/dashboard/project.vue';
import { mockProjectData } from '../../mock_data';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('project header component', () => {
  let wrapper;
  let store;
  let projects;

  const addPath = 'add-path';
  const listPath = 'list-path';
  const emptyDashboardSvgPath = 'empty-dashboard-svg-path';
  const emptyDashboardHelpPath = 'empty-dashboard-help-path';

  const findDashboardSkeleton = () => wrapper.find(GlDashboardSkeleton);
  const findEmptyState = () => wrapper.find(GlEmptyState);
  const findAddProjectButton = () => wrapper.find('.js-add-projects-button');
  const findTitle = () => wrapper.find('.js-dashboard-title');
  const findProjects = () => wrapper.findAll(Project);

  const createComponent = ({ actions = {}, props = {}, state = {}, stubs = {} } = {}) => {
    store = new Vuex.Store({
      actions: {
        addProjectsToDashboard() {},
        clearSearchResults() {},
        fetchNextPage() {},
        fetchProjects() {},
        fetchSearchResults() {},
        setProjectEndpoints() {},
        setProjects() {},
        setSearchQuery() {},
        toggleSelectedProject() {},
        ...actions,
      },
      state: {
        isLoadingProjects: false,
        messages: [],
        pageInfo: {},
        projects: [],
        projectSearchResults: [],
        searchCount: 0,
        selectedProjects: [],
        ...state,
      },
    });

    wrapper = shallowMount(Dashboard, {
      localVue,
      store,
      propsData: {
        addPath,
        listPath,
        emptyDashboardSvgPath,
        emptyDashboardHelpPath,
        ...props,
      },
      stubs,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    jest.clearAllMocks();
  });

  describe('when loading', () => {
    beforeEach(() => {
      createComponent({
        state: {
          isLoadingProjects: true,
        },
      });
    });

    it('should render the skeleton loading state', () => {
      expect(findDashboardSkeleton().exists()).toBe(true);
    });
  });

  describe('when no projects have been added', () => {
    beforeEach(() => {
      createComponent({
        stubs: {
          GlEmptyState,
        },
      });
    });

    it('should render the empty state', () => {
      expect(findEmptyState().exists()).toBe(true);
    });

    it('should link to the documentation', () => {
      const link = findEmptyState().find('.js-documentation-link');

      expect(link.exists()).toBe(true);
      expect(link.attributes().href).toEqual(emptyDashboardHelpPath);
    });

    it('should render the add projects button', () => {
      const button = findAddProjectButton();

      expect(button.exists()).toBe(true);
      expect(button.text()).toEqual('Add projects');
    });
  });

  describe('with two projects loaded', () => {
    beforeEach(() => {
      projects = mockProjectData(2);
      createComponent({
        state: { projects },
      });
    });

    it('should render the title', () => {
      expect(findTitle().text()).toEqual('Operations Dashboard');
    });

    it('should render the add projects button', () => {
      expect(findAddProjectButton().exists()).toBe(true);
    });

    it('should include a dashboard project component for each project', () => {
      expect(findProjects()).toHaveLength(projects.length);
    });

    it('should pass project data to the project component', () => {
      const firstProject = findProjects().at(0);

      expect(firstProject.props().project).toEqual(projects[0]);
    });
  });
});
