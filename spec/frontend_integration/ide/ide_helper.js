/* eslint-disable jest/no-standalone-expect */
import MockAdapter from 'axios-mock-adapter';
import {
  getSnapshotDiffSerializer,
  snapshotDiff,
  defaultSerializers,
  setSerializers,
} from 'snapshot-diff';
import { initIde } from '~/ide';
import gql from '~/ide/services/gql';
import axios from '~/lib/utils/axios_utils';
import useLocationHelper from '../helpers/location_helper';
import useDefaultHelper from '../helpers/default_helper';
import createCleanHTMLSerializer from '../helpers/clean_html_snapshot_serializer';
import { mockProject, mockBranch, mockFiles } from './mock_data';

const TEST_DATASET = {
  emptyStateSvgPath: '/test/empty_state.svg',
  noChangesStateSvgPath: '/test/no_changes_state.svg',
  committedStateSvgPath: '/test/committed_state.svg',
  pipelinesEmptyStateSvgPath: '/test/pipelines_empty_state.svg',
  promotionSvgPath: '/test/promotion.svg',
  ciHelpPagePath: '/test/ci_help_page',
  webIDEHelpPagePath: '/test/web_ide_help_page',
  clientsidePreviewEnabled: 'true',
  renderWhitespaceInCode: 'false',
  codesandboxBundlerUrl: 'test/codesandbox_bundler',
};

jest.mock('~/ide/services/gql');

const TEST_PROJECT_PATH = 'gitlab-test/test';

const useTestHelper = () => {
  let root;
  let vm;
  let axiosMock;
  let prevNode;

  expect.addSnapshotSerializer(createCleanHTMLSerializer());
  setSerializers([...defaultSerializers, createCleanHTMLSerializer(true)]);
  expect.addSnapshotSerializer(getSnapshotDiffSerializer());

  const { setup: setupLocation, destroy: destroyLocation } = useLocationHelper();
  const {
    setup: setupDefault,
    destroy: destroyDefault,
    apiVersion,
    waitForAxios,
  } = useDefaultHelper();

  return {
    setup() {
      root = document.createElement('div');

      axiosMock = new MockAdapter(axios);

      setupLocation({ pathname: `/-/ide/project/${TEST_PROJECT_PATH}` });
      setupDefault();
    },

    destroy() {
      vm.$destroy();
      vm = null;
      root = null;
      prevNode = null;

      axiosMock.restore();

      destroyLocation();
      destroyDefault();
    },

    mount() {
      const el = document.createElement('div');
      Object.assign(el.dataset, TEST_DATASET);
      root.appendChild(el);
      vm = initIde(el);
    },

    withProjectData() {
      const API_PROJECT_PATH = `/api/${apiVersion}/projects/${encodeURIComponent(
        TEST_PROJECT_PATH,
      )}`;

      axiosMock.onGet(API_PROJECT_PATH).reply(200, mockProject);
      axiosMock.onGet(`${API_PROJECT_PATH}/repository/branches/master`).reply(200, mockBranch);
      axiosMock.onGet(`${API_PROJECT_PATH}/merge_requests`).reply(200, []);
      axiosMock
        .onGet(`/${TEST_PROJECT_PATH}/-/files/${mockBranch.commit.id}`)
        .reply(200, mockFiles);
      axiosMock
        .onGet(`/${TEST_PROJECT_PATH}/commit/${mockBranch.commit.id}/pipelines`)
        .reply(200, { pipelines: [], count: { all: 0 } });

      gql.query.mockResolvedValue({
        data: {
          project: {
            userPermissions: {
              createMergeRequestIn: true,
              readMergeRequest: true,
              pushCode: true,
            },
          },
        },
      });
    },

    expectSnapshot() {
      expect(root).toMatchSnapshot();
      prevNode = root.cloneNode(true);
    },

    expectDiffSnapshot() {
      expect(snapshotDiff(prevNode, root)).toMatchSnapshot();
      prevNode = root.cloneNode(true);
    },

    nextTick() {
      return vm.$nextTick();
    },

    waitForRequests() {
      return waitForAxios().then(() => {
        jest.runOnlyPendingTimers();
      });
    },
  };
};

export default useTestHelper;
