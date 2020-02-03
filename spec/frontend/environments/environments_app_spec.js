import { mount, shallowMount } from '@vue/test-utils';
import axios from '~/lib/utils/axios_utils';
import MockAdapter from 'axios-mock-adapter';
import Container from '~/environments/components/container.vue';
import EmptyState from '~/environments/components/empty_state.vue';
import EnvironmentsApp from '~/environments/components/environments_app.vue';
import { environment, folder } from './mock_data';

describe('Environment', () => {
  let mock;
  let wrapper;

  const mockData = {
    canaryDeploymentFeatureId: 'canary_deployment',
    canCreateEnvironment: true,
    canReadEnvironment: true,
    endpoint: 'environments.json',
    helpCanaryDeploymentsPath: 'help/canary-deployments',
    helpPagePath: 'help',
    lockPromotionSvgPath: '/assets/illustrations/lock-promotion.svg',
    newEnvironmentPath: 'environments/new',
    showCanaryDeploymentCallout: true,
    userCalloutsPath: '/callouts',
  };

  const mockEnvironments = environmentList => {
    mock.onGet(mockData.endpoint).reply(
      200,
      {
        environments: environmentList,
        stopped_count: 1,
        available_count: 0,
      },
      {
        'X-nExt-pAge': '2',
        'x-page': '1',
        'X-Per-Page': '1',
        'X-Prev-Page': '',
        'X-TOTAL': '37',
        'X-Total-Pages': '2',
      },
    );
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('successful request', () => {
    describe('without environments', () => {
      beforeEach(done => {
        mockEnvironments([]);
        wrapper = shallowMount(EnvironmentsApp, { propsData: mockData });

        setImmediate(() => {
          done();
        });
      });

      it('should render the empty state', () => {
        expect(wrapper.find(EmptyState).exists()).toBe(true);
      });
    });

    describe('with paginated environments', () => {
      const environmentList = [environment];

      beforeEach(done => {
        mockEnvironments(environmentList);

        wrapper = mount(EnvironmentsApp, { propsData: mockData });

        setImmediate(() => {
          done();
        });
      });

      it('should render a conatiner table with environments', () => {
        const containerTable = wrapper.find(Container);

        expect(containerTable.exists()).toBe(true);
        expect(containerTable.props('environments').length).toEqual(environmentList.length);
        expect(containerTable.find('.environment-name').text()).toEqual(environmentList[0].name);
      });

      describe('pagination', () => {
        it('should render pagination', () => {
          expect(wrapper.findAll('.gl-pagination li').length).toEqual(9);
        });

        it('should make an API request when page is clicked', () => {
          jest.spyOn(wrapper.vm, 'updateContent').mockImplementation(() => {});

          wrapper.find('.gl-pagination li:nth-child(3) .page-link').trigger('click');
          expect(wrapper.vm.updateContent).toHaveBeenCalledWith({ scope: 'available', page: '2' });
        });

        it('should make an API request when using tabs', () => {
          jest.spyOn(wrapper.vm, 'updateContent').mockImplementation(() => {});
          wrapper.find('.js-environments-tab-stopped').trigger('click');
          expect(wrapper.vm.updateContent).toHaveBeenCalledWith({ scope: 'stopped', page: '1' });
        });
      });
    });
  });

  describe('unsuccessfull request', () => {
    beforeEach(done => {
      mock.onGet(mockData.endpoint).reply(500, {});
      wrapper = shallowMount(EnvironmentsApp, { propsData: mockData });

      setImmediate(() => {
        done();
      });
    });

    it('should render empty state', () => {
      expect(wrapper.find(EmptyState).exists()).toBe(true);
    });
  });

  describe('expandable folders', () => {
    beforeEach(done => {
      mockEnvironments([folder]);
      mock.onGet(environment.folder_path).reply(200, { environments: [environment] });

      wrapper = mount(EnvironmentsApp, { propsData: mockData });

      setImmediate(() => {
        done();
      });
    });

    it('should open a closed folder', done => {
      wrapper.find('.folder-name').trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.folder-icon.ic-chevron-right').exists()).toBe(false);
        done();
      });
    });

    it('should close an opened folder', done => {
      // open folder
      wrapper.find('.folder-name').trigger('click');
      wrapper.vm.$nextTick(() => {
        expect(wrapper.find('.folder-icon.ic-chevron-down').exists()).toBe(true);

        // close folder
        wrapper.find('.folder-name').trigger('click');
        wrapper.vm.$nextTick(() => {
          expect(wrapper.find('.folder-icon.ic-chevron-down').exists()).toBe(false);
          done();
        });
      });
    });

    it('should show children environments and a button to show all environments', done => {
      // open folder
      wrapper.find('.folder-name').trigger('click');

      setImmediate(() => {
        expect(wrapper.findAll('.js-child-row').length).toEqual(1);

        expect(wrapper.find('.text-center > a.btn').text()).toContain('Show all');
        done();
      });
    });
  });

  describe('methods', () => {
    beforeEach(() => {
      mockEnvironments([]);
      wrapper = shallowMount(EnvironmentsApp, { propsData: mockData });
      jest.spyOn(window.history, 'pushState').mockImplementation(() => {});
    });

    describe('updateContent', () => {
      it('should set given parameters', done => {
        wrapper.vm
          .updateContent({ scope: 'stopped', page: '3' })
          .then(() => {
            expect(wrapper.vm.page).toEqual('3');
            expect(wrapper.vm.scope).toEqual('stopped');
            expect(wrapper.vm.requestData.scope).toEqual('stopped');
            expect(wrapper.vm.requestData.page).toEqual('3');
            done();
          })
          .catch(done.fail);
      });
    });

    describe('onChangeTab', () => {
      it('should set page to 1', () => {
        jest.spyOn(wrapper.vm, 'updateContent').mockImplementation(() => {});
        wrapper.vm.onChangeTab('stopped');
        expect(wrapper.vm.updateContent).toHaveBeenCalledWith({ scope: 'stopped', page: '1' });
      });
    });

    describe('onChangePage', () => {
      it('should update page and keep scope', () => {
        jest.spyOn(wrapper.vm, 'updateContent').mockImplementation(() => {});
        wrapper.vm.onChangePage(4);
        expect(wrapper.vm.updateContent).toHaveBeenCalledWith({
          scope: wrapper.vm.scope,
          page: '4',
        });
      });
    });
  });
});
