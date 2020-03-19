import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import { set } from 'lodash';
import { TEST_HOST } from 'helpers/test_constants';

import SecurityDashboardApp from 'ee/security_dashboard/components/app.vue';
import Filters from 'ee/security_dashboard/components/filters.vue';
import IssueModal from 'ee/vue_shared/security_reports/components/modal.vue';
import SecurityDashboardTable from 'ee/security_dashboard/components/security_dashboard_table.vue';
import VulnerabilityChart from 'ee/security_dashboard/components/vulnerability_chart.vue';
import VulnerabilityCountList from 'ee/security_dashboard/components/vulnerability_count_list.vue';
import VulnerabilitySeverity from 'ee/security_dashboard/components/vulnerability_severity.vue';
import LoadingError from 'ee/security_dashboard/components/loading_error.vue';

import createStore from 'ee/security_dashboard/store';
import { getParameterValues } from '~/lib/utils/url_utility';
import axios from '~/lib/utils/axios_utils';

const pipelineId = 123;
const vulnerabilitiesEndpoint = `${TEST_HOST}/vulnerabilities`;
const vulnerabilitiesCountEndpoint = `${TEST_HOST}/vulnerabilities_summary`;
const vulnerabilitiesHistoryEndpoint = `${TEST_HOST}/vulnerabilities_history`;
const vulnerableProjectsEndpoint = `${TEST_HOST}/vulnerable_projects`;
const vulnerabilityFeedbackHelpPath = `${TEST_HOST}/vulnerabilities_feedback_help`;

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('Security Dashboard app', () => {
  let wrapper;
  let mock;
  let lockFilterSpy;
  let setPipelineIdSpy;
  let store;

  const setup = () => {
    mock = new MockAdapter(axios);
    lockFilterSpy = jest.fn();
    setPipelineIdSpy = jest.fn();
  };

  const createComponent = props => {
    store = createStore();
    wrapper = shallowMount(SecurityDashboardApp, {
      store,
      methods: {
        lockFilter: lockFilterSpy,
        setPipelineId: setPipelineIdSpy,
      },
      propsData: {
        dashboardDocumentation: '',
        vulnerabilitiesEndpoint,
        vulnerabilitiesCountEndpoint,
        vulnerabilitiesHistoryEndpoint,
        vulnerableProjectsEndpoint,
        pipelineId,
        vulnerabilityFeedbackHelpPath,
        ...props,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    mock.restore();
  });

  describe('default', () => {
    beforeEach(() => {
      setup();
      createComponent();
    });

    it('renders the filters', () => {
      expect(wrapper.find(Filters).exists()).toBe(true);
    });

    it('renders the security dashboard table ', () => {
      expect(wrapper.find(SecurityDashboardTable).exists()).toBe(true);
    });

    it('renders the vulnerability chart', () => {
      expect(wrapper.find(VulnerabilityChart).exists()).toBe(true);
    });

    it('does not render the vulnerability count list', () => {
      expect(wrapper.find(VulnerabilityCountList).exists()).toBe(false);
    });

    it('does not lock to a project', () => {
      expect(wrapper.vm.isLockedToProject).toBe(false);
    });

    it('does not lock project filters', () => {
      expect(lockFilterSpy).not.toHaveBeenCalled();
    });

    it('sets the pipeline id', () => {
      expect(setPipelineIdSpy).toHaveBeenCalledWith(pipelineId);
    });

    describe('when the total number of vulnerabilities change', () => {
      const newCount = 3;

      beforeEach(() => {
        store.state.vulnerabilities.pageInfo = { total: newCount };
      });

      it('emits a vulnerabilitiesCountChanged event', () => {
        expect(wrapper.emitted('vulnerabilitiesCountChanged')).toEqual([[newCount]]);
      });
    });

    describe('issues modal', () => {
      const mockModalData = {
        vulnerability: {
          create_vulnerability_feedback_issue_path: '',
          create_vulnerability_feedback_merge_request_path: '',
        },
      };

      beforeEach(() => {
        wrapper.vm.$store.state.vulnerabilities.modal = mockModalData;
        return wrapper.vm.$nextTick();
      });

      it('includes the modal', () => {
        expect(wrapper.find(IssueModal).exists()).toBe(true);
      });

      it.each`
        givenStatePath                                                    | hasValue          | propName                       | expectedPropValue
        ${'modal'}                                                        | ${{ foo: 'bar' }} | ${'modal'}                     | ${{ foo: 'bar' }}
        ${'modal.vulnerability.create_vulnerability_feedback_issue_path'} | ${null}           | ${'canCreateIssue'}            | ${false}
        ${'modal.vulnerability.create_vulnerability_feedback_issue_path'} | ${'foo'}          | ${'canCreateIssue'}            | ${true}
        ${'isCreatingIssue'}                                              | ${false}          | ${'isCreatingIssue'}           | ${false}
        ${'isCreatingIssue'}                                              | ${true}           | ${'isCreatingIssue'}           | ${true}
        ${'isCreatingIssue'}                                              | ${false}          | ${'isCreatingIssue'}           | ${false}
        ${'isDismissingVulnerability'}                                    | ${true}           | ${'isDismissingVulnerability'} | ${true}
      `(
        'given the state at "$givenStatePath" is "$hasValue" it passes "$expectedPropValue" to the "$propName" prop',
        ({ givenStatePath, hasValue, propName, expectedPropValue }) => {
          set(wrapper.vm.$store.state.vulnerabilities, givenStatePath, hasValue);
          return wrapper.vm.$nextTick().then(() => {
            expect(wrapper.find(IssueModal).props(propName)).toStrictEqual(expectedPropValue);
          });
        },
      );

      // it.each`
      //   statePath | value | modalData                                                                         | prop                       | expectedPropValue
      //   ${}${{ foo: 'bar' }}                                                                 | ${'modal'}                 | ${{ foo: 'bar' }}
      //   ${{ vulnerability: { create_vulnerability_feedback_issue_path: null } }}          | ${'canCreateIssue'}        | ${false}
      //   ${{ vulnerability: { create_vulnerability_feedback_issue_path: 'foo' } }}         | ${'canCreateIssue'}        | ${true}
      //   ${{ vulnerability: { create_vulnerability_feedback_merge_request_path: null } }}  | ${'canCreateMergeRequest'} | ${false}
      //   ${{ vulnerability: { create_vulnerability_feedback_merge_request_path: 'foo' } }} | ${'canCreateMergeRequest'} | ${true}
      //   ${{ vulnerability: { create_vulnerability_feedback_merge_request_path: 'foo' } }} | ${'isCreatingIssue'}       | ${false}
      // `('passes the right prop to the modal', ({ prop, modalData, expectedPropValue }) => {
      //   wrapper.vm.$store.state.vulnerabilities.modal = modalData;
      //
      //   return wrapper.vm.$nextTick().then(() => {
      //     expect(wrapper.find(IssueModal).props(prop)).toStrictEqual(expectedPropValue);
      //   });
      // });
    });
  });

  describe('with project lock', () => {
    const project = {
      id: 123,
    };
    beforeEach(() => {
      setup();
      createComponent({
        lockToProject: project,
      });
    });

    it('renders the vulnerability count list', () => {
      expect(wrapper.find(VulnerabilityCountList).exists()).toBe(true);
    });

    it('locks to a given project', () => {
      expect(wrapper.vm.isLockedToProject).toBe(true);
    });

    it('locks the filters to a given project', () => {
      expect(lockFilterSpy).toHaveBeenCalledWith({
        filterId: 'project_id',
        optionId: project.id,
      });
    });
  });

  describe.each`
    endpointProp                        | Component
    ${'vulnerabilitiesCountEndpoint'}   | ${VulnerabilityCountList}
    ${'vulnerabilitiesHistoryEndpoint'} | ${VulnerabilityChart}
    ${'vulnerableProjectsEndpoint'}     | ${VulnerabilitySeverity}
  `('with an empty $endpointProp', ({ endpointProp, Component }) => {
    beforeEach(() => {
      setup();
      createComponent({
        [endpointProp]: '',
      });
    });

    it(`does not show the ${Component.name}`, () => {
      expect(wrapper.find(Component).exists()).toBe(false);
    });
  });

  describe('dismissed vulnerabilities', () => {
    beforeEach(() => {
      setup();
    });

    it.each`
      description                                                        | getParameterValuesReturnValue | expected
      ${'hides dismissed vulnerabilities by default'}                    | ${[]}                         | ${true}
      ${'shows dismissed vulnerabilities if scope param is "all"'}       | ${['all']}                    | ${false}
      ${'hides dismissed vulnerabilities if scope param is "dismissed"'} | ${['dismissed']}              | ${true}
    `('$description', ({ getParameterValuesReturnValue, expected }) => {
      getParameterValues.mockImplementation(() => getParameterValuesReturnValue);
      createComponent();
      expect(wrapper.vm.$store.state.filters.hideDismissed).toBe(expected);
    });
  });

  describe('on error', () => {
    beforeEach(() => {
      setup();
      createComponent();
    });

    it.each([401, 403])('displays an error on error %s', errorCode => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(LoadingError).exists()).toBe(true);
      });
    });

    it.each([404, 500])('does not display an error on error %s', errorCode => {
      store.dispatch('vulnerabilities/receiveVulnerabilitiesError', errorCode);
      return wrapper.vm.$nextTick().then(() => {
        expect(wrapper.find(LoadingError).exists()).toBe(false);
      });
    });
  });
});
