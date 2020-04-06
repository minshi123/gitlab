import { mount } from '@vue/test-utils';
import ActiveToggle from '~/integrations/edit/components/active_toggle.vue';
import { GlToggle } from '@gitlab/ui';

const GL_TOGGLE_ACTIVE_CLASS = 'is-checked';

describe('ActiveToggle', () => {
  let wrapper;

  const defaultProps = {
    showActive: true,
    initialActivated: true,
    disabled: false,
  };

  const createComponent = props => {
    wrapper = mount(ActiveToggle, {
      propsData: Object.assign({}, defaultProps, props),
    });
  };

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  const containsGlToggle = () => wrapper.contains(GlToggle);
  const findToggle = () => wrapper.find('button');
  const findToggleInput = () => wrapper.find('input');

  describe('template', () => {
    describe('when showActive is false', () => {
      it('does not render anything', () => {
        createComponent({
          showActive: false,
        });
        expect(containsGlToggle()).toBe(false);
      });
    });

    describe('when showActive is true, initialActivated is false', () => {
      it('renders GlToggle as inactive', () => {
        createComponent({
          initialActivated: false,
        });
        expect(containsGlToggle()).toBe(true);
        expect(findToggle().classes()).not.toContain(GL_TOGGLE_ACTIVE_CLASS);
      });
    });

    describe('when showActive is true, initialActivated is true', () => {
      it('renders GlToggle as active', () => {
        createComponent();
        expect(containsGlToggle()).toBe(true);
        expect(findToggle().classes()).toContain(GL_TOGGLE_ACTIVE_CLASS);
      });
    });
  });

  describe('on toggle click', () => {
    it('switches the form value', () => {
      createComponent();

      expect(findToggle().classes()).toContain(GL_TOGGLE_ACTIVE_CLASS);
      expect(findToggleInput().attributes('value')).toBe('true');

      findToggle().trigger('click');

      wrapper.vm.$nextTick(() => {
        expect(findToggle().classes()).not.toContain(GL_TOGGLE_ACTIVE_CLASS);
        expect(findToggleInput().attributes('value')).toBe('false');
      });
    });
  });
});
