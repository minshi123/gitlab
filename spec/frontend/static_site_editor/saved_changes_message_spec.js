import { shallowMount } from '@vue/test-utils';
import { GlLink, GlNewButton } from '@gitlab/ui';
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
  const findReturnToSiteGlNewButton = () => wrapper.find({ ref: 'returnToSiteNewButton' });
  const findMergeRequestGlNewButton = () => wrapper.find({ ref: 'mergeRequestNewButton' });
  const findBranchGlLink = () => wrapper.find({ ref: 'branchLink' });
  const findCommitGlLink = () => wrapper.find({ ref: 'commitLink' });
  const findMergeRequestGlLink = () => wrapper.find({ ref: 'mergeRequestLink' });

  beforeEach(() => {
    wrapper = shallowMount(SavedChangesMessage, {
      propsData: props,
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('GlNewButton usage', () => {
    it('renders exactly two GlNewButton instances', () => {
      expect(wrapper.findAll(GlNewButton).length).toBe(2);
    });

    describe('GlNewButton returnToSite', () => {
      it('renders a GlNewButton for the returnToSite prop', () => {
        expect(findReturnToSiteGlNewButton().exists()).toBe(true);
      });

      it('sets the returnToSiteNewButton href to the returnToSite prop', () => {
        expect(findReturnToSiteGlNewButton().attributes().href).toBe(props.returnUrl);
      });
    });

    describe('GlNewButton mergeRequestNewButton', () => {
      it('renders a GlNewButton for the mergeRequest prop', () => {
        expect(findMergeRequestGlNewButton().exists()).toBe(true);
      });

      it('sets the mergeRequestNewButton href to the url of the mergeRequest prop', () => {
        expect(findMergeRequestGlNewButton().attributes().href).toBe(props.mergeRequest.url);
      });
    });
  });

  describe('GlLink usage', () => {
    it('renders exactly three GlLink instances', () => {
      expect(wrapper.findAll(GlLink).length).toBe(3);
    });

    describe('GlLink branchLink', () => {
      it('renders a GlLink for the branch prop', () => {
        expect(findBranchGlLink().exists()).toBe(true);
      });

      it('sets the branchLink href and label via the branch prop', () => {
        expect(findBranchGlLink().attributes().href).toBe(props.branch.url);
        expect(findBranchGlLink().text()).toBe(props.branch.label);
      });
    });

    describe('GlLink commitLink', () => {
      it('renders a GlLink for the commit prop', () => {
        expect(findCommitGlLink().exists()).toBe(true);
      });

      it('sets the commitLink href and label via the commit prop', () => {
        expect(findCommitGlLink().attributes().href).toBe(props.commit.url);
        expect(findCommitGlLink().text()).toBe(props.commit.label);
      });
    });

    describe('GlLink mergeRequestLink', () => {
      it('renders a GlLink for the mergeRequest prop', () => {
        expect(findMergeRequestGlLink().exists()).toBe(true);
      });

      it('sets the mergeRequestLink href and label via the mergeRequest prop', () => {
        expect(findMergeRequestGlLink().attributes().href).toBe(props.mergeRequest.url);
        expect(findMergeRequestGlLink().text()).toBe(props.mergeRequest.label);
      });
    });
  });
});
