import { shallowMount } from '@vue/test-utils';
import GroupedIssuesList from '~/reports/components/grouped_issues_list.vue';
import ReportItem from '~/reports/components/report_item.vue';
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';

describe('Grouped Issues List', () => {
  let wrapper;

  const getPropsData = (resolvedIssues, unresolvedIssues) => ({
    groups: [
      {
        name: 'resolved',
        heading: 'Resolved Heading Text',
        issues: resolvedIssues,
      },
      {
        name: 'unresolved',
        heading: 'Unresolved Heading Text',
        issues: unresolvedIssues,
      },
    ],
  });

  const createComponent = ({ resolvedIssues = [], unresolvedIssues = [], stubs = {} } = {}) => {
    wrapper = shallowMount(GroupedIssuesList, {
      propsData: getPropsData(resolvedIssues, unresolvedIssues),
      stubs,
    });
  };

  const findHeading = groupName => wrapper.find(`[data-testid="${groupName}"`);

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('renders a smart virtual list with the correct props', () => {
    createComponent({
      resolvedIssues: [{ name: 'foo' }],
      unresolvedIssues: [{ name: 'bar' }],
      stubs: {
        SmartVirtualList,
      },
    });

    expect(wrapper.find(SmartVirtualList).props()).toMatchSnapshot();
  });

  describe('without data', () => {
    beforeEach(createComponent);

    it.each(['unresolved', 'resolved'])('does not a render a header for %s issues', issueName => {
      expect(findHeading(issueName).exists()).toBe(false);
    });

    it.each('resolved', 'unresolved')('does not render report items for %s issues', () => {
      expect(wrapper.contains(ReportItem)).toBe(false);
    });
  });

  describe('with data', () => {
    it.each`
      givenIssues                                | groupName       | expectedHeadingText
      ${{ resolvedIssues: [{ name: 'foo' }] }}   | ${'resolved'}   | ${getPropsData().groups[0].heading}
      ${{ unresolvedIssues: [{ name: 'bar' }] }} | ${'unresolved'} | ${getPropsData().groups[1].heading}
    `(
      'renders the correct heading for $groupName issues',
      ({ givenIssues, groupName, expectedHeadingText }) => {
        createComponent(givenIssues);

        expect(findHeading(groupName).text()).toContain(expectedHeadingText);
      },
    );

    it.each(['resolved', 'unresolved'])('renders all %s issues', issueName => {
      const issues = [{ name: 'foo' }, { name: 'bar' }];

      createComponent({
        [`${issueName}Issues`]: issues,
      });

      expect(wrapper.findAll(ReportItem)).toHaveLength(issues.length);
    });

    it('renders a report item with the correct props', () => {
      createComponent({
        resolvedIssues: [{ name: 'foo' }],
        stubs: {
          ReportItem,
        },
      });

      expect(wrapper.find(ReportItem).props()).toMatchSnapshot();
    });
  });
});
