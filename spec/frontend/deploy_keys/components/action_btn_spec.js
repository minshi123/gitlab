import { shallowMount } from '@vue/test-utils';
import eventHub from '~/deploy_keys/eventhub';
import actionBtn from '~/deploy_keys/components/action_btn.vue';

describe('Deploy keys action btn', () => {
  const data = getJSONFixture('deploy_keys/keys.json');
  const deployKey = data.enabled_keys[0];
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(actionBtn, {
      propsData: {
        deployKey,
        type: 'enable',
      },
      slots: {
        default: 'Enable',
      },
    });
  });

  it('renders the default slot', () => {
    expect(wrapper.text()).toBe('Enable');
  });

  it('sends eventHub event with btn type', () => {
    jest.spyOn(eventHub, '$emit').mockImplementation(() => {});

    wrapper.trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(eventHub.$emit).toHaveBeenCalledWith('enable.key', deployKey, expect.anything());
    });
  });

  it('shows loading spinner after click', () => {
    wrapper.trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.vm.$el.querySelector('.fa')).toBeDefined();
    });
  });

  it('disables button after click', () => {
    wrapper.trigger('click');

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.vm.$el.classList.contains('disabled')).toBeTruthy();

      expect(wrapper.vm.$el.getAttribute('disabled')).toBe('disabled');
    });
  });
});
