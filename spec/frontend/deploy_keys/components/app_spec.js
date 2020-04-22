import { mount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { TEST_HOST } from 'spec/test_constants';
import waitForPromises from 'helpers/wait_for_promises';
import axios from '~/lib/utils/axios_utils';
import eventHub from '~/deploy_keys/eventhub';
import deployKeysApp from '~/deploy_keys/components/app.vue';
import DeployKeysStore from '~/deploy_keys/store/';

describe('Deploy keys app component', () => {
  const data = getJSONFixture('deploy_keys/keys.json');
  let defaultStore = {};
  let wrapper;
  let mock;

  const mountComponent = (dataOverride = {}, methods) => {
    wrapper = mount(deployKeysApp, {
      propsData: {
        endpoint: `${TEST_HOST}/dummy`,
        projectId: '8',
      },
      data() {
        return { store: defaultStore, ...dataOverride };
      },
      methods,
    });
    return waitForPromises();
  };

  beforeEach(() => {
    defaultStore = new DeployKeysStore();
    mock = new MockAdapter(axios);
    mock.onGet(`${TEST_HOST}/dummy/`).replyOnce(200, data);
  });

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  it('renders loading icon', () => {
    defaultStore.keys = {};
    return mountComponent({ isLoading: true }, { fetchKeys: jest.fn() }).then(() => {
      expect(wrapper.find('.gl-spinner').exists()).toBe(true);
    });
  });

  it('renders keys panels', () => {
    return mountComponent().then(() => {
      expect(wrapper.findAll('.deploy-keys .nav-links li').length).toBe(3);
    });
  });

  it('renders the titles with keys count', () => {
    return mountComponent().then(() => {
      const textContent = selector => {
        const element = wrapper.find(selector);

        expect(element).not.toBeNull();
        return element.text().trim();
      };

      expect(textContent('.js-deployKeys-tab-enabled_keys')).toContain('Enabled deploy keys');
      expect(textContent('.js-deployKeys-tab-available_project_keys')).toContain(
        'Privately accessible deploy keys',
      );

      expect(textContent('.js-deployKeys-tab-public_keys')).toContain(
        'Publicly accessible deploy keys',
      );

      expect(textContent('.js-deployKeys-tab-enabled_keys .badge')).toBe(
        `${defaultStore.keys.enabled_keys.length}`,
      );

      expect(textContent('.js-deployKeys-tab-available_project_keys .badge')).toBe(
        `${defaultStore.keys.available_project_keys.length}`,
      );

      expect(textContent('.js-deployKeys-tab-public_keys .badge')).toBe(
        `${defaultStore.keys.public_keys.length}`,
      );
    });
  });

  it('does not render key panels when keys object is empty', () => {
    defaultStore.keys = {};
    return mountComponent({}, { fetchKeys: jest.fn() }).then(() => {
      expect(wrapper.findAll('.deploy-keys .nav-links li').length).toBe(0);
    });
  });

  it('re-fetches deploy keys when enabling a key', () => {
    const key = data.public_keys[0];
    return mountComponent()
      .then(() => {
        jest.spyOn(wrapper.vm.service, 'getKeys').mockImplementation(() => {});
        jest.spyOn(wrapper.vm.service, 'enableKey').mockImplementation(() => Promise.resolve());

        eventHub.$emit('enable.key', key);

        return wrapper.vm.$nextTick();
      })
      .then(() => {
        expect(wrapper.vm.service.enableKey).toHaveBeenCalledWith(key.id);
        expect(wrapper.vm.service.getKeys).toHaveBeenCalled();
      });
  });

  it('re-fetches deploy keys when disabling a key', () => {
    const key = data.public_keys[0];
    return mountComponent()
      .then(() => {
        jest.spyOn(window, 'confirm').mockReturnValue(true);
        jest.spyOn(wrapper.vm.service, 'getKeys').mockImplementation(() => {});
        jest.spyOn(wrapper.vm.service, 'disableKey').mockImplementation(() => Promise.resolve());

        eventHub.$emit('disable.key', key);

        return wrapper.vm.$nextTick();
      })
      .then(() => {
        expect(wrapper.vm.service.disableKey).toHaveBeenCalledWith(key.id);
        expect(wrapper.vm.service.getKeys).toHaveBeenCalled();
      });
  });

  it('calls disableKey when removing a key', () => {
    const key = data.public_keys[0];
    return mountComponent()
      .then(() => {
        jest.spyOn(window, 'confirm').mockReturnValue(true);
        jest.spyOn(wrapper.vm.service, 'getKeys').mockImplementation(() => {});
        jest.spyOn(wrapper.vm.service, 'disableKey').mockImplementation(() => Promise.resolve());

        eventHub.$emit('remove.key', key);

        return wrapper.vm.$nextTick();
      })
      .then(() => {
        expect(wrapper.vm.service.disableKey).toHaveBeenCalledWith(key.id);
        expect(wrapper.vm.service.getKeys).toHaveBeenCalled();
      });
  });

  it('hasKeys returns true when there are keys', () => {
    return mountComponent().then(() => {
      expect(wrapper.vm.hasKeys).toEqual(3);
    });
  });
});
