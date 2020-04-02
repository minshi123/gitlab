import { shallowMount } from '@vue/test-utils';

import InvalidContentMessage from '~/static_site_editor/components/invalid_content_message.vue';

describe('InvalidContentMessage', () => {
  let wrapper;
  const props = {
    configureUrl: 'https://www.the-static-site.com/configure',
  };
  const findConfigureSiteButton = () => wrapper.find({ ref: 'configureSiteButton' });

  beforeEach(() => {
    wrapper = shallowMount(InvalidContentMessage, {
      propsData: props,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders the configuration button link', () => {
    expect(findConfigureSiteButton().exists()).toBe(true);
    expect(findConfigureSiteButton().attributes('href')).toBe(props.configureUrl);
  });
});
