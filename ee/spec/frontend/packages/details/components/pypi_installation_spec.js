import Vuex from 'vuex';
import { mount, createLocalVue } from '@vue/test-utils';
import PypiInstallation from 'ee/packages/details/components/pypi_installation.vue';
import { TrackingActions, TrackingLabels } from 'ee/packages/details/constants';
import { pypiPackage as packageEntity } from '../../mock_data';
import Tracking from '~/tracking';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('PypiInstallation', () => {
  let wrapper;

  const pipCommandStr = 'pip install';
  const pypiSetupStr = 'python setup';

  const store = new Vuex.Store({
    state: {
      packageEntity,
      pypiHelpPath: 'foo',
    },
    getters: {
      pypiPipCommand: () => pipCommandStr,
      pypiSetupCommand: () => pypiSetupStr,
    },
  });

  const installationTab = () => wrapper.find('.js-installation-tab > a');
  const setupTab = () => wrapper.find('.js-setup-tab > a');
  const setupInstruction = () => wrapper.find('.js-pypi-setup-content > pre');
  const pipCommand = () => wrapper.find('.js-pip-command > input');

  function createComponent() {
    wrapper = mount(PypiInstallation, {
      localVue,
      store,
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('installation commands', () => {
    it('renders the correct pip command', () => {
      expect(pipCommand().element.value).toBe(pipCommandStr);
    });
  });

  describe('setup commands', () => {
    it('renders the correct setup block', () => {
      expect(setupInstruction().text()).toBe(pypiSetupStr);
    });
  });

  describe('tab change tracking', () => {
    let eventSpy;
    const label = TrackingLabels.PYPI_INSTALLATION;

    beforeEach(() => {
      eventSpy = jest.spyOn(Tracking, 'event');
    });

    it('should track when the setup tab is clicked', () => {
      setupTab().trigger('click');

      return wrapper.vm.$nextTick(() => {
        expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.REGISTRY_SETUP, {
          label,
        });
      });
    });

    it('should track when the installation tab is clicked', () => {
      setupTab().trigger('click');
      return wrapper.vm
        .$nextTick()
        .then(() => {
          installationTab().trigger('click');
        })
        .then(() => {
          expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.INSTALLATION, {
            label,
          });
        });
    });
  });
});
