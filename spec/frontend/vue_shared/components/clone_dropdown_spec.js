import CloneDropdown from '~/vue_shared/components/clone_dropdown.vue';
import { shallowMount } from '@vue/test-utils';
import { GlFormInputGroup } from '@gitlab/ui';

describe('Clone Dropdown Button', () => {
  let wrapper;
  const sshLink = 'ssh://foo.bar';
  const httpLink = 'http://foo.bar';

  const createComponent = () => {
    wrapper = shallowMount(CloneDropdown, {
      propsData: {
        sshLink,
        httpLink,
      },
      stubs: {
        'gl-form-input-group': GlFormInputGroup,
      },
    });
  };

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('rendering', () => {
    it('matches the snapshot', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    it.each`
      name      | selector                     | value
      ${'SSH'}  | ${'#clone-snippet-ssh-url'}  | ${sshLink}
      ${'HTTP'} | ${'#clone-snippet-http-url'} | ${httpLink}
    `('renders correct link and a copy-button for $name', ({ selector, value }) => {
      expect(wrapper.find(`${selector}`).props('value')).toBe(value);
      expect(wrapper.contains(`[data-clipboard-target="${selector}"]`)).toBe(true);
    });
  });
});
