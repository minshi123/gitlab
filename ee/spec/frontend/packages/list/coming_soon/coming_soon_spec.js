import { GlEmptyState, GlSkeletonLoader } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ComingSoon from 'ee/packages/list/coming_soon/coming_soon.vue';
import { modifiedIssues } from './mock_data';

describe('coming_soon', () => {
  let wrapper;

  const defaultProps = {
    issues: modifiedIssues,
    isLoading: false,
    illustration: 'foo',
  };

  const findSkeletonLoader = () => wrapper.find(GlSkeletonLoader);
  const findAllIssues = () => wrapper.findAll({ ref: 'issue-row' });
  const findWorkflowLabels = () => wrapper.findAll({ ref: 'workflow-label' });
  const findContributionsLabels = () => wrapper.findAll({ ref: 'contributions-label' });
  const findEmptyState = () => wrapper.find(GlEmptyState);

  const mountComponent = (props = {}) => {
    wrapper = shallowMount(ComingSoon, {
      propsData: {
        ...defaultProps,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when loading', () => {
    beforeEach(() => mountComponent({ isLoading: true }));

    it('renders the skeleton loader', () => {
      expect(findSkeletonLoader().exists()).toBe(true);
    });
  });

  describe('when there are no issues', () => {
    beforeEach(() => mountComponent({ issues: [] }));

    it('renders the skeleton loader', () => {
      expect(findEmptyState().exists()).toBe(true);
    });
  });

  describe('when there are issues', () => {
    beforeEach(() => mountComponent());

    it('renders each issue', () => {
      expect(findAllIssues()).toHaveLength(modifiedIssues.length);
    });

    it('renders two in dev labels', () => {
      expect(findWorkflowLabels()).toHaveLength(2);
    });

    it('renders two contribution labels', () => {
      expect(findContributionsLabels()).toHaveLength(2);
    });
  });
});
