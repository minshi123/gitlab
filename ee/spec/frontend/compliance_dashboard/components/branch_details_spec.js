import { mount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';

import BranchDetails from 'ee/compliance_dashboard/components/branch_details.vue';

describe('BranchDetails component', () => {
  let wrapper;

  const createComponent = ({ sourceUri = '', targetUri = '' } = {}) => {
    return mount(BranchDetails, {
      propsData: {
        sourceBranch: {
          name: 'feature',
          uri: sourceUri,
        },
        targetBranch: {
          name: 'master',
          uri: targetUri,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  describe('with branch details', () => {
    describe('and no branch URIs', () => {
      beforeEach(() => {
        wrapper = createComponent();
      });

      it('has no links', () => {
        expect(wrapper.find(GlLink).exists()).toBe(false);
      });

      it('has the correct text', () => {
        expect(wrapper.text()).toEqual('feature into master');
      });
    });

    describe('and one branch URI', () => {
      beforeEach(() => {
        wrapper = createComponent({ targetUri: '/master-uri' });
      });

      it('has one link', () => {
        expect(wrapper.findAll(GlLink)).toHaveLength(1);
      });

      it('has a link to the target branch', () => {
        expect(wrapper.find('[data-testid="target-branch-uri"]').exists()).toBe(true);
      });

      it('has the correct text', () => {
        expect(wrapper.text()).toEqual('feature into master');
      });
    });

    describe('and both branch URIs', () => {
      beforeEach(() => {
        wrapper = createComponent({ sourceUri: '/feature-uri', targetUri: '/master-uri' });
      });

      it('has two links', () => {
        expect(wrapper.findAll(GlLink)).toHaveLength(2);
      });

      it('has a link to the source branch', () => {
        expect(wrapper.find('[data-testid="source-branch-uri"]').exists()).toBe(true);
      });

      it('has a link to the target branch', () => {
        expect(wrapper.find('[data-testid="target-branch-uri"]').exists()).toBe(true);
      });

      it('has the correct text', () => {
        expect(wrapper.text()).toEqual('feature into master');
      });
    });
  });
});
