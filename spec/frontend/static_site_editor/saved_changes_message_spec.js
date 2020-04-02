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

  it('renders Return to site button link', () => {
    expect(findReturnToSiteButton().exists()).toBe(true);
    expect(findReturnToSiteButton().attributes('href')).toBe(props.returnUrl);
  });

  it('renders Merge request button link', () => {
    expect(findMergeRequestButton().exists()).toBe(true);
    expect(findMergeRequestButton().attributes('href')).toBe(props.mergeRequest.url);
  });

  it('renders branch link', () => {
    expect(findBranchLink().exists()).toBe(true);
    expect(findBranchLink().attributes().href).toBe(props.branch.url);
    expect(findBranchLink().text()).toBe(props.branch.label);
  });

  it('renders commit link', () => {
    expect(findCommitLink().exists()).toBe(true);
    expect(findCommitLink().attributes().href).toBe(props.commit.url);
    expect(findCommitLink().text()).toBe(props.commit.label);
  });

  it('renders merge request link', () => {
    expect(findMergeRequestLink().exists()).toBe(true);
    expect(findMergeRequestLink().attributes().href).toBe(props.mergeRequest.url);
    expect(findMergeRequestLink().text()).toBe(props.mergeRequest.label);
  });
});
