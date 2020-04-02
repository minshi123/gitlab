import { shallowMount } from '@vue/test-utils';
import { GlAlert } from '@gitlab/ui';
import component from '~/registry/settings/components/registry_settings_app.vue';
import SettingsForm from '~/registry/settings/components/settings_form.vue';
import { createStore } from '~/registry/settings/store/';
import { SET_SETTINGS } from '~/registry/settings/store/mutation_types';
import { FETCH_SETTINGS_ERROR_MESSAGE } from '~/registry/shared/constants';

describe('Registry Settings App', () => {
  let wrapper;
  let store;

  const findSettingsComponent = () => wrapper.find(SettingsForm);
  const findAlert = () => wrapper.find(GlAlert);

  const mountComponent = ({ dispatchMock = 'mockResolvedValue', emptySettings } = {}) => {
    store = createStore();
    const dispatchSpy = jest.spyOn(store, 'dispatch');
    dispatchSpy[dispatchMock]();

    if (emptySettings) {
      store.commit(SET_SETTINGS, undefined);
    }

    wrapper = shallowMount(component, {
      mocks: {
        $toast: {
          show: jest.fn(),
        },
      },
      store,
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders', () => {
    mountComponent();
    expect(wrapper.element).toMatchSnapshot();
  });

  it('call the store function to load the data on mount', () => {
    mountComponent();
    expect(store.dispatch).toHaveBeenCalledWith('fetchSettings');
  });

  it('renders the setting form', () => {
    mountComponent();
    expect(findSettingsComponent().exists()).toBe(true);
  });

  describe('the form is disabled', () => {
    beforeEach(() => {
      mountComponent({ emptySettings: true });
    });

    it('the form is hidden', () => {
      expect(findSettingsComponent().exists()).toBe(false);
    });

    it('shows an alert', () => {
      expect(findAlert().html()).toContain(
        'Currently, the Container Registry tag expiration feature is disabled',
      );
    });
  });

  describe('fetchSettingsError', () => {
    beforeEach(() => {
      mountComponent({ dispatchMock: 'mockRejectedValue' });
    });

    it('the form is hidden', () => {
      expect(findSettingsComponent().exists()).toBe(false);
    });

    it('shows an alert', () => {
      expect(findAlert().html()).toContain(FETCH_SETTINGS_ERROR_MESSAGE);
    });
  });
});
