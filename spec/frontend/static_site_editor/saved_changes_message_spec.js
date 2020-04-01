import { mount } from '@vue/test-utils';
import SavedChangesMessage from '~/static_site_editor/components/saved_changes_message.vue';

describe('SavedChangesMessage', () => {
  let wrapper;
  const props = {
    returnUrl: 'https://www.the-static-site.com/post',
    links: {
      branch: {
        label: '123-the-branch',
        url: 'https://gitlab.com/gitlab-org/gitlab/-/tree/123-the-branch',
      },
      commit: {
        label: 'a123',
        url: 'https://gitlab.com/gitlab-org/gitlab/-/commit/a123',
      },
      mergeRequest: {
        label: '123',
        url: 'https://gitlab.com/gitlab-org/gitlab/-/merge_requests/123',
      },
    },
  };

  beforeEach(() => {
    wrapper = mount(SavedChangesMessage, {
      propsData: props,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('has a valid returnUrl string prop', () => {
    expect(typeof wrapper.props('returnUrl')).toBe('string');
  });

  it('has a valid links object prop', () => {
    const links = wrapper.props('links');

    expect(typeof links).toBe('object');

    expect(links.branch).toBeDefined();
    expect(links.commit).toBeDefined();
    expect(links.mergeRequest).toBeDefined();

    Object.keys(links).forEach(key => {
      const link = links[key];

      expect(typeof link).toBe('object');
      expect(link).toHaveProperty('label');
      expect(typeof link.label).toBe('string');
      expect(link).toHaveProperty('url');
      expect(typeof link.url).toBe('string');
    });
  });
});
