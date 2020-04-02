import { shallowMount } from '@vue/test-utils';

import SavedChangesMessage from '~/static_site_editor/components/saved_changes_message.vue';

describe('SavedChangesMessage', () => {
  let wrapper;
  const props = {
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
    returnUrl: 'https://www.the-static-site.com/post',
  };
  const findReturnToSiteButton = () => wrapper.find({ ref: 'returnToSiteButton' });
  const findMergeRequestButton = () => wrapper.find({ ref: 'mergeRequestButton' });
  const findBranchLink = () => wrapper.find({ ref: 'branchLink' });
  const findCommitLink = () => wrapper.find({ ref: 'commitLink' });
  const findMergeRequestLink = () => wrapper.find({ ref: 'mergeRequestLink' });

  beforeEach(() => {
    wrapper = shallowMount(SavedChangesMessage, {
      propsData: props,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  const buttonLinks = [
    ['Return to site', findReturnToSiteButton, props.returnUrl],
    ['Merge request', findMergeRequestButton, props.mergeRequest.url],
  ];
  it.each(buttonLinks)('renders %s button link', (_, findEl, url) => {
    expect(findEl().exists()).toBe(true);
    expect(findEl().attributes('href')).toBe(url);
  });

  const links = [
    ['branch', findBranchLink, props.branch],
    ['commit', findCommitLink, props.commit],
    ['merge request', findMergeRequestLink, props.mergeRequest],
  ];
  it.each(links)('renders %s link', (_, findEl, prop) => {
    expect(findEl().exists()).toBe(true);
    expect(findEl().attributes().href).toBe(prop.url);
    expect(findEl().text()).toBe(prop.label);
  });
});
