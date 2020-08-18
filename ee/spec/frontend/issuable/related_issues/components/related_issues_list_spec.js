import { mount } from '@vue/test-utils';
import IssueWeight from 'ee/boards/components/issue_card_weight.vue';
import RelatedIssuesList from '~/related_issues/components/related_issues_list.vue';
import { issuable1 } from 'jest/vue_shared/components/issue/related_issuable_mock_data';
import { PathIdSeparator } from '~/related_issues/constants';

describe('RelatedIssuesList', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  describe('related item contents', () => {
    beforeAll(() => {
      wrapper = mount(RelatedIssuesList, {
        propsData: {
          issuableType: 'issue',
          pathIdSeparator: PathIdSeparator.Issue,
          relatedIssues: [issuable1],
        },
      });
    });

    it('shows weight', () => {
      expect(
        wrapper
          .find(IssueWeight)
          .find('.board-card-info-text')
          .text(),
      ).toBe(issuable1.weight.toString());
    });
  });
});
