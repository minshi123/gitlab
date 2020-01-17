import { shallowMount } from '@vue/test-utils';
import component from '~/registry/settings/components/registry_settings_app.vue';
import { FETCH_SETTINGS_ERROR_MESSAGE } from '~/registry/settings/constants';

describe('Registry Settings App', () => {
  let wrapper;
  let fetchSpy;

  const findSettingsComponent = () => wrapper.find({ ref: 'settings-form' });

  const mountComponent = (options = {}) => {
    wrapper = shallowMount(component, {
      mocks: {
        $toast: {
          show: jest.fn(),
        },
      },
      methods: {
        fetchSettings: fetchSpy,
      },
      ...options,
    });
  };

  beforeEach(() => {
    fetchSpy = jest.fn().mockResolvedValue();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders', () => {
    mountComponent();
    expect(wrapper.element).toMatchSnapshot();
  });

  it('call the store function to load the data on mount', () => {
    mountComponent();
    expect(fetchSpy).toHaveBeenCalled();
  });

  it('show a toast if fetchSettings fails', () => {
    fetchSpy = jest.fn().mockRejectedValue();
    mountComponent();
    return wrapper.vm.$nextTick().then(() =>
      expect(wrapper.vm.$toast.show).toHaveBeenCalledWith(FETCH_SETTINGS_ERROR_MESSAGE, {
        type: 'error',
      }),
    );
  });

  it('renders the setting form', () => {
    mountComponent();
    expect(findSettingsComponent().exists()).toBe(true);
  });
});
