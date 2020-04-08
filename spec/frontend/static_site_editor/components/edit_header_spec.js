import { shallowMount } from '@vue/test-utils';

import EditHeader from '~/static_site_editor/components/edit_header.vue';

describe('~/static_site_editor/components/edit_header.vue', () => {
  let wrapper;
  const url = 'https://www.gitlab.com';

  const findReturnUrlLink = () => wrapper.find({ ref: 'returnUrlLink' });

  const buildWrapper = (props = {}) => {
    wrapper = shallowMount(EditHeader, {
      propsData: props,
    });
  };

  describe('when returnUrl prop does not exist', () => {
    beforeEach(buildWrapper);
    afterEach(() => {
      wrapper.destroy();
    });

    it('does not render returnUrl link', () => {
      expect(findReturnUrlLink().exists()).toBe(false);
    });
  });

  describe('when returnUrl prop exists', () => {
    beforeEach(() => buildWrapper({ returnUrl: url }));
    afterEach(() => {
      wrapper.destroy();
    });

    it('renders returnUrl link', () => {
      expect(findReturnUrlLink().exists()).toBe(true);
      expect(findReturnUrlLink().attributes('href')).toBe(url);
    });
  });
});
