import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import * as actions from 'ee/analytics/cycle_analytics/store/actions';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';
import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import {
  selectedGroup,
  allowedStages as stages,
  startDate,
  endDate,
  customizableStagesAndEvents,
  endpoints,
  valueStreams,
} from '../mock_data';

const stageData = { events: [] };
const error = new Error(`Request failed with status code ${httpStatusCodes.NOT_FOUND}`);
const flashErrorMessage = 'There was an error while fetching value stream analytics data.';

stages[0].hidden = true;
const activeStages = stages.filter(({ hidden }) => !hidden);
const hiddenStage = stages[0];

const [selectedStage] = activeStages;
const selectedStageSlug = selectedStage.slug;
const [selectedValueStream] = valueStreams;

const mockGetters = {
  currentGroupPath: () => selectedGroup.fullPath,
  currentValueStreamId: () => selectedValueStream.id,
};

const stageEndpoint = ({ stageId }) =>
  `/groups/${selectedGroup.fullPath}/-/analytics/value_stream_analytics/value_streams/${selectedValueStream.id}/stages/${stageId}`;

jest.mock('~/flash');

describe('Cycle analytics actions', () => {
  let state;
  let mock;

  const shouldFlashAMessage = (msg, type = null) => {
    const args = type ? [msg, type] : [msg];
    expect(createFlash).toHaveBeenCalledWith(...args);
  };

  beforeEach(() => {
    state = {
      startDate,
      endDate,
      stages: [],
      featureFlags: {
        hasDurationChart: true,
        hasDurationChartMedian: true,
      },
      activeStages,
      selectedValueStream,
      ...mockGetters,
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    state = { ...state, selectedGroup: null };
  });

  it.each`
    action                   | type                       | stateKey                | payload
    ${'setFeatureFlags'}     | ${'SET_FEATURE_FLAGS'}     | ${'featureFlags'}       | ${{ hasDurationChart: true }}
    ${'setSelectedProjects'} | ${'SET_SELECTED_PROJECTS'} | ${'selectedProjectIds'} | ${[10, 20, 30, 40]}
    ${'setSelectedStage'}    | ${'SET_SELECTED_STAGE'}    | ${'selectedStage'}      | ${{ id: 'someStageId' }}
  `('$action should set $stateKey with $payload and type $type', ({ action, type, payload }) => {
    return testAction(
      actions[action],
      payload,
      state,
      [
        {
          type,
          payload,
        },
      ],
      [],
    );
  });

  describe('setSelectedValueStream', () => {
    const vs = { id: 'vs-1', name: 'Value stream 1' };

    it('refetches the cycle analytics data', () => {
      return testAction(
        actions.setSelectedValueStream,
        vs,
        { ...state, selectedValueStream: {} },
        [{ type: types.SET_SELECTED_VALUE_STREAM, payload: vs }],
        [
          { type: 'fetchGroupStagesAndEvents' },
          { type: 'fetchStageMedianValues' },
          { type: 'durationChart/fetchDurationData' },
        ],
      );
    });
  });

  describe('setDateRange', () => {
    const payload = { startDate, endDate };

    it('dispatches the fetchCycleAnalyticsData action', () => {
      return testAction(
        actions.setDateRange,
        payload,
        state,
        [{ type: types.SET_DATE_RANGE, payload: { startDate, endDate } }],
        [{ type: 'fetchCycleAnalyticsData' }],
      );
    });
  });

  describe('setSelectedGroup', () => {
    it('commits the setSelectedGroup mutation', () => {
      return testAction(
        actions.setSelectedGroup,
        { ...selectedGroup },
        state,
        [{ type: types.SET_SELECTED_GROUP, payload: selectedGroup }],
        [],
      );
    });

    describe('with hasFilterBar=true', () => {
      beforeEach(() => {
        state = {
          ...state,
          featureFlags: {
            ...state.featureFlags,
            hasFilterBar: true,
          },
        };
        mock = new MockAdapter(axios);
      });

      it('commits the setSelectedGroup mutation', () => {
        return testAction(
          actions.setSelectedGroup,
          { full_path: selectedGroup.fullPath },
          state,
          [{ type: types.SET_SELECTED_GROUP, payload: { full_path: selectedGroup.fullPath } }],
          [
            {
              type: 'filters/initialize',
              payload: {
                groupPath: selectedGroup.fullPath,
              },
            },
          ],
        );
      });
    });
  });

  describe('fetchStageData', () => {
    beforeEach(() => {
      state = { ...state, selectedGroup };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageData).reply(httpStatusCodes.OK, { events: [] });
    });

    it('dispatches receiveStageDataSuccess with received data on success', () => {
      return testAction(
        actions.fetchStageData,
        selectedStageSlug,
        state,
        [],
        [
          { type: 'requestStageData' },
          {
            type: 'receiveStageDataSuccess',
            payload: { events: [] },
          },
        ],
      );
    });

    describe('with a failing request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onGet(endpoints.stageData).replyOnce(httpStatusCodes.NOT_FOUND, { error });
      });

      it('dispatches receiveStageDataError on error', () => {
        return testAction(
          actions.fetchStageData,
          selectedStage,
          state,
          [],
          [
            {
              type: 'requestStageData',
            },
            {
              type: 'receiveStageDataError',
              payload: error,
            },
          ],
        );
      });
    });

    describe('receiveStageDataSuccess', () => {
      it(`commits the ${types.RECEIVE_STAGE_DATA_SUCCESS} mutation`, () => {
        return testAction(
          actions.receiveStageDataSuccess,
          { ...stageData },
          state,
          [{ type: types.RECEIVE_STAGE_DATA_SUCCESS, payload: { events: [] } }],
          [],
        );
      });
    });
  });

  describe('receiveStageDataError', () => {
    beforeEach(() => {});
    it(`commits the ${types.RECEIVE_STAGE_DATA_ERROR} mutation`, () => {
      return testAction(
        actions.receiveStageDataError,
        null,
        state,
        [
          {
            type: types.RECEIVE_STAGE_DATA_ERROR,
          },
        ],
        [],
      );
    });

    it('will flash an error message', () => {
      actions.receiveStageDataError({ commit: () => {} });
      shouldFlashAMessage('There was an error fetching data for the selected stage');
    });
  });

  describe('fetchCycleAnalyticsData', () => {
    function mockFetchCycleAnalyticsAction(overrides = {}) {
      const mocks = {
        requestCycleAnalyticsData:
          overrides.requestCycleAnalyticsData || jest.fn().mockResolvedValue(),
        fetchStageMedianValues: overrides.fetchStageMedianValues || jest.fn().mockResolvedValue(),
        fetchGroupStagesAndEvents:
          overrides.fetchGroupStagesAndEvents || jest.fn().mockResolvedValue(),
        receiveCycleAnalyticsDataSuccess:
          overrides.receiveCycleAnalyticsDataSuccess || jest.fn().mockResolvedValue(),
      };
      return {
        mocks,
        mockDispatchContext: jest
          .fn()
          .mockImplementationOnce(mocks.requestCycleAnalyticsData)
          .mockImplementationOnce(mocks.fetchGroupStagesAndEvents)
          .mockImplementationOnce(mocks.fetchStageMedianValues)
          .mockImplementationOnce(mocks.receiveCycleAnalyticsDataSuccess),
      };
    }

    beforeEach(() => {
      state = { ...state, selectedGroup, startDate, endDate };
    });

    it(`dispatches actions for required value stream analytics analytics data`, () => {
      return testAction(
        actions.fetchCycleAnalyticsData,
        state,
        null,
        [],
        [
          { type: 'requestCycleAnalyticsData' },
          { type: 'fetchValueStreams' },
          { type: 'receiveCycleAnalyticsDataSuccess' },
        ],
      );
    });

    it(`displays an error if fetchStageMedianValues fails`, () => {
      const { mockDispatchContext } = mockFetchCycleAnalyticsAction({
        fetchStageMedianValues: actions.fetchStageMedianValues({
          dispatch: jest
            .fn()
            .mockResolvedValueOnce()
            .mockImplementation(actions.receiveStageMedianValuesError({ commit: () => {} })),
          commit: () => {},
          state: { ...state },
          getters: {
            ...getters,
            activeStages,
          },
        }),
      });

      return actions
        .fetchCycleAnalyticsData({
          dispatch: mockDispatchContext,
          state: {},
          commit: () => {},
        })
        .then(() => {
          shouldFlashAMessage('There was an error fetching median data for stages');
        });
    });

    it(`displays an error if fetchGroupStagesAndEvents fails`, () => {
      const { mockDispatchContext } = mockFetchCycleAnalyticsAction({
        fetchGroupStagesAndEvents: actions.fetchGroupStagesAndEvents({
          dispatch: jest
            .fn()
            .mockResolvedValueOnce()
            .mockImplementation(actions.receiveGroupStagesError({ commit: () => {} })),
          commit: () => {},
          state: { ...state },
          getters,
        }),
      });

      return actions
        .fetchCycleAnalyticsData({
          dispatch: mockDispatchContext,
          state: {},
          commit: () => {},
        })
        .then(() => {
          shouldFlashAMessage('There was an error fetching value stream analytics stages.');
        });
    });
  });

  describe('receiveCycleAnalyticsDataError', () => {
    beforeEach(() => {});

    it(`commits the ${types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR} mutation on a 403 response`, () => {
      const response = { status: 403 };
      return testAction(
        actions.receiveCycleAnalyticsDataError,
        { response },
        state,
        [
          {
            type: types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR,
            payload: response.status,
          },
        ],
        [],
      );
    });

    it(`commits the ${types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR} mutation on a non 403 error response`, () => {
      const response = { status: 500 };
      return testAction(
        actions.receiveCycleAnalyticsDataError,
        { response },
        state,
        [
          {
            type: types.RECEIVE_CYCLE_ANALYTICS_DATA_ERROR,
            payload: response.status,
          },
        ],
        [],
      );
    });

    it('will flash an error when the response is not 403', () => {
      const response = { status: 500 };
      actions.receiveCycleAnalyticsDataError(
        {
          commit: () => {},
        },
        { response },
      );

      shouldFlashAMessage(flashErrorMessage);
    });
  });

  describe('receiveGroupStagesSuccess', () => {
    beforeEach(() => {});

    it(`commits the ${types.RECEIVE_GROUP_STAGES_SUCCESS} mutation and dispatches 'setDefaultSelectedStage'`, () => {
      return testAction(
        actions.receiveGroupStagesSuccess,
        { ...customizableStagesAndEvents.stages },
        state,
        [
          {
            type: types.RECEIVE_GROUP_STAGES_SUCCESS,
            payload: { ...customizableStagesAndEvents.stages },
          },
        ],
        [{ type: 'setDefaultSelectedStage' }],
      );
    });
  });

  describe('setDefaultSelectedStage', () => {
    it("dispatches the 'fetchStageData' action", () => {
      return testAction(
        actions.setDefaultSelectedStage,
        null,
        state,
        [],
        [
          { type: 'setSelectedStage', payload: selectedStage },
          { type: 'fetchStageData', payload: selectedStageSlug },
        ],
      );
    });

    it.each`
      data
      ${[]}
      ${null}
    `('with $data will flash an error', ({ data }) => {
      actions.setDefaultSelectedStage({ getters: { activeStages: data }, dispatch: () => {} }, {});
      shouldFlashAMessage(flashErrorMessage);
    });

    it('will select the first active stage', () => {
      return testAction(
        actions.setDefaultSelectedStage,
        null,
        state,
        [],
        [
          { type: 'setSelectedStage', payload: stages[1] },
          { type: 'fetchStageData', payload: stages[1].slug },
        ],
      );
    });
  });

  describe('updateStage', () => {
    const stageId = 'cool-stage';
    const payload = { hidden: true };

    beforeEach(() => {
      mock.onPut(stageEndpoint({ stageId }), payload).replyOnce(httpStatusCodes.OK, payload);
    });

    it('dispatches receiveUpdateStageSuccess and customStages/setSavingCustomStage', () => {
      return testAction(
        actions.updateStage,
        {
          id: stageId,
          ...payload,
        },
        state,
        [],
        [
          { type: 'requestUpdateStage' },
          { type: 'customStages/setSavingCustomStage' },
          {
            type: 'receiveUpdateStageSuccess',
            payload,
          },
        ],
      );
    });

    describe('with a failed request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it('dispatches receiveUpdateStageError', () => {
        const data = {
          id: stageId,
          name: 'issue',
          ...payload,
        };
        return testAction(
          actions.updateStage,
          data,
          state,
          [],
          [
            { type: 'requestUpdateStage' },
            { type: 'customStages/setSavingCustomStage' },
            {
              type: 'receiveUpdateStageError',
              payload: {
                status: httpStatusCodes.NOT_FOUND,
                data,
              },
            },
          ],
        );
      });

      it('flashes an error if the stage name already exists', () => {
        return actions
          .receiveUpdateStageError(
            {
              commit: () => {},
              dispatch: () => Promise.resolve(),
              state,
            },
            {
              status: httpStatusCodes.UNPROCESSABLE_ENTITY,
              responseData: {
                errors: { name: ['is reserved'] },
              },
              data: {
                name: stageId,
              },
            },
          )
          .then(() => {
            shouldFlashAMessage(`'${stageId}' stage already exists`);
          });
      });

      it('flashes an error message', () => {
        return actions
          .receiveUpdateStageError(
            {
              dispatch: () => Promise.resolve(),
              commit: () => {},
              state,
            },
            { status: httpStatusCodes.BAD_REQUEST },
          )
          .then(() => {
            shouldFlashAMessage('There was a problem saving your custom stage, please try again');
          });
      });
    });

    describe('receiveUpdateStageSuccess', () => {
      const response = {
        title: 'NEW - COOL',
      };

      it('will dispatch fetchGroupStagesAndEvents', () =>
        testAction(
          actions.receiveUpdateStageSuccess,
          response,
          state,
          [{ type: types.RECEIVE_UPDATE_STAGE_SUCCESS }],
          [
            { type: 'fetchGroupStagesAndEvents' },
            { type: 'customStages/showEditForm', payload: response },
          ],
        ));

      it('will flash a success message', () => {
        return actions
          .receiveUpdateStageSuccess(
            {
              dispatch: () => {},
              commit: () => {},
            },
            response,
          )
          .then(() => {
            shouldFlashAMessage('Stage data updated', 'notice');
          });
      });

      describe('with an error', () => {
        it('will flash an error message', () =>
          actions
            .receiveUpdateStageSuccess(
              {
                dispatch: () => Promise.reject(),
                commit: () => {},
              },
              response,
            )
            .then(() => {
              shouldFlashAMessage('There was a problem refreshing the data, please try again');
            }));
      });
    });
  });

  describe('removeStage', () => {
    const stageId = 'cool-stage';

    beforeEach(() => {
      mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
    });

    it('dispatches receiveRemoveStageSuccess with put request response data', () => {
      return testAction(
        actions.removeStage,
        stageId,
        state,
        [],
        [
          { type: 'requestRemoveStage' },
          {
            type: 'receiveRemoveStageSuccess',
          },
        ],
      );
    });

    describe('with a failed request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it('dispatches receiveRemoveStageError', () => {
        return testAction(
          actions.removeStage,
          stageId,
          state,
          [],
          [
            { type: 'requestRemoveStage' },
            {
              type: 'receiveRemoveStageError',
              payload: error,
            },
          ],
        );
      });

      it('flashes an error message', () => {
        actions.receiveRemoveStageError({ commit: () => {}, state }, {});
        shouldFlashAMessage('There was an error removing your custom stage, please try again');
      });
    });
  });

  describe('receiveRemoveStageSuccess', () => {
    const stageId = 'cool-stage';

    beforeEach(() => {
      mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
      state = { selectedGroup };
    });

    it('dispatches fetchCycleAnalyticsData', () => {
      return testAction(
        actions.receiveRemoveStageSuccess,
        stageId,
        state,
        [{ type: 'RECEIVE_REMOVE_STAGE_RESPONSE' }],
        [{ type: 'fetchCycleAnalyticsData' }],
      );
    });

    it('flashes a success message', () => {
      return actions
        .receiveRemoveStageSuccess(
          {
            dispatch: () => Promise.resolve(),
            commit: () => {},
            state,
          },
          {},
        )
        .then(() => shouldFlashAMessage('Stage removed', 'notice'));
    });
  });

  describe('fetchStageMedianValues', () => {
    let mockDispatch = jest.fn();
    const fetchMedianResponse = activeStages.map(({ slug: id }) => ({ events: [], id }));

    beforeEach(() => {
      state = { ...state, stages, selectedGroup };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageMedian).reply(httpStatusCodes.OK, { events: [] });
      mockDispatch = jest.fn();
    });

    it('dispatches receiveStageMedianValuesSuccess with received data on success', () => {
      return testAction(
        actions.fetchStageMedianValues,
        null,
        state,
        [],
        [
          { type: 'requestStageMedianValues' },
          { type: 'receiveStageMedianValuesSuccess', payload: fetchMedianResponse },
        ],
      );
    });

    it('does not request hidden stages', () => {
      return actions
        .fetchStageMedianValues({
          state,
          getters: {
            ...getters,
            activeStages,
          },
          commit: () => {},
          dispatch: mockDispatch,
        })
        .then(() => {
          expect(mockDispatch).not.toHaveBeenCalledWith('receiveStageMedianValuesSuccess', {
            events: [],
            id: hiddenStage.id,
          });
        });
    });

    describe('with a failing request', () => {
      beforeEach(() => {
        mock.onGet(endpoints.stageMedian).reply(httpStatusCodes.NOT_FOUND, { error });
      });

      it('will dispatch receiveStageMedianValuesError', () => {
        return testAction(
          actions.fetchStageMedianValues,
          null,
          state,
          [],
          [
            { type: 'requestStageMedianValues' },
            { type: 'receiveStageMedianValuesError', payload: error },
          ],
        );
      });
    });
  });

  describe('receiveStageMedianValuesError', () => {
    it(`commits the ${types.RECEIVE_STAGE_MEDIANS_ERROR} mutation`, () =>
      testAction(
        actions.receiveStageMedianValuesError,
        null,
        state,
        [
          {
            type: types.RECEIVE_STAGE_MEDIANS_ERROR,
          },
        ],
        [],
      ));

    it('will flash an error message', () => {
      actions.receiveStageMedianValuesError({ commit: () => {} });
      shouldFlashAMessage('There was an error fetching median data for stages');
    });
  });

  describe('receiveStageMedianValuesSuccess', () => {
    it(`commits the ${types.RECEIVE_STAGE_MEDIANS_SUCCESS} mutation`, () => {
      return testAction(
        actions.receiveStageMedianValuesSuccess,
        { ...stageData },
        state,
        [{ type: types.RECEIVE_STAGE_MEDIANS_SUCCESS, payload: { events: [] } }],
        [],
      );
    });
  });

  describe('initializeCycleAnalytics', () => {
    let mockDispatch;
    let mockCommit;
    let store;

    const initialData = {
      group: selectedGroup,
      projectIds: [1, 2],
    };

    beforeEach(() => {
      mockDispatch = jest.fn(() => Promise.resolve());
      mockCommit = jest.fn();
      store = {
        state,
        getters,
        commit: mockCommit,
        dispatch: mockDispatch,
      };
    });

    describe('with no initialData', () => {
      it('commits "INITIALIZE_CYCLE_ANALYTICS"', () =>
        actions.initializeCycleAnalytics(store).then(() => {
          expect(mockCommit).toHaveBeenCalledWith('INITIALIZE_CYCLE_ANALYTICS', {});
        }));

      it('dispatches "initializeCycleAnalyticsSuccess"', () =>
        actions.initializeCycleAnalytics(store).then(() => {
          expect(mockDispatch).not.toHaveBeenCalledWith('fetchCycleAnalyticsData');
          expect(mockDispatch).toHaveBeenCalledWith('initializeCycleAnalyticsSuccess');
        }));
    });

    describe('with initialData', () => {
      it('dispatches "fetchCycleAnalyticsData" and "initializeCycleAnalyticsSuccess"', () =>
        actions.initializeCycleAnalytics(store, initialData).then(() => {
          expect(mockDispatch).toHaveBeenCalledWith('fetchCycleAnalyticsData');
          expect(mockDispatch).toHaveBeenCalledWith('initializeCycleAnalyticsSuccess');
        }));

      it('commits "INITIALIZE_CYCLE_ANALYTICS"', () =>
        actions.initializeCycleAnalytics(store, initialData).then(() => {
          expect(mockCommit).toHaveBeenCalledWith('INITIALIZE_CYCLE_ANALYTICS', initialData);
        }));
    });
  });

  describe('initializeCycleAnalyticsSuccess', () => {
    it(`commits the ${types.INITIALIZE_CYCLE_ANALYTICS_SUCCESS} mutation`, () =>
      testAction(
        actions.initializeCycleAnalyticsSuccess,
        null,
        state,
        [{ type: types.INITIALIZE_CYCLE_ANALYTICS_SUCCESS }],
        [],
      ));
  });

  describe('reorderStage', () => {
    const stageId = 'cool-stage';
    const payload = { id: stageId, move_after_id: '2', move_before_id: '8' };

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
      });

      it(`dispatches the ${types.REQUEST_REORDER_STAGE} and ${types.RECEIVE_REORDER_STAGE_SUCCESS} actions`, () => {
        return testAction(
          actions.reorderStage,
          payload,
          state,
          [],
          [{ type: 'requestReorderStage' }, { type: 'receiveReorderStageSuccess' }],
        );
      });
    });

    describe('with errors', () => {
      beforeEach(() => {
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it(`dispatches the ${types.REQUEST_REORDER_STAGE} and ${types.RECEIVE_REORDER_STAGE_ERROR} actions `, () => {
        return testAction(
          actions.reorderStage,
          payload,
          state,
          [],
          [
            { type: 'requestReorderStage' },
            { type: 'receiveReorderStageError', payload: { status: httpStatusCodes.NOT_FOUND } },
          ],
        );
      });
    });
  });

  describe('receiveReorderStageError', () => {
    beforeEach(() => {});

    it(`commits the ${types.RECEIVE_REORDER_STAGE_ERROR} mutation and flashes an error`, () => {
      return testAction(
        actions.receiveReorderStageError,
        null,
        state,
        [
          {
            type: types.RECEIVE_REORDER_STAGE_ERROR,
          },
        ],
        [],
      ).then(() => {
        shouldFlashAMessage(
          'There was an error updating the stage order. Please try reloading the page.',
        );
      });
    });
  });

  describe('receiveReorderStageSuccess', () => {
    it(`commits the ${types.RECEIVE_REORDER_STAGE_SUCCESS} mutation`, () => {
      return testAction(
        actions.receiveReorderStageSuccess,
        null,
        state,
        [{ type: types.RECEIVE_REORDER_STAGE_SUCCESS }],
        [],
      );
    });
  });

  describe('createValueStream', () => {
    const payload = { name: 'cool value stream' };

    beforeEach(() => {
      state = { selectedGroup };
    });

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onPost(endpoints.valueStreamData).replyOnce(httpStatusCodes.OK, {});
      });

      it(`commits the ${types.REQUEST_CREATE_VALUE_STREAM} and ${types.RECEIVE_CREATE_VALUE_STREAM_SUCCESS} actions`, () => {
        return testAction(
          actions.createValueStream,
          payload,
          state,
          [
            {
              type: types.REQUEST_CREATE_VALUE_STREAM,
            },
          ],
          [{ type: 'receiveCreateValueStreamSuccess' }],
        );
      });
    });

    describe('with errors', () => {
      const errors = { name: ['is taken'] };
      const message = { message: 'error' };
      const resp = { message, payload: { errors } };
      beforeEach(() => {
        mock.onPost(endpoints.valueStreamData).replyOnce(httpStatusCodes.NOT_FOUND, resp);
      });

      it(`commits the ${types.REQUEST_CREATE_VALUE_STREAM} and ${types.RECEIVE_CREATE_VALUE_STREAM_ERROR} actions `, () => {
        return testAction(
          actions.createValueStream,
          payload,
          state,
          [
            { type: types.REQUEST_CREATE_VALUE_STREAM },
            {
              type: types.RECEIVE_CREATE_VALUE_STREAM_ERROR,
              payload: { message, errors },
            },
          ],
          [],
        );
      });
    });
  });

  describe('fetchValueStreams', () => {
    beforeEach(() => {
      state = {
        ...state,
        stages: [{ slug: selectedStageSlug }],
        selectedGroup,
        featureFlags: {
          ...state.featureFlags,
          hasCreateMultipleValueStreams: true,
        },
      };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.valueStreamData).reply(httpStatusCodes.OK, { stages: [], events: [] });
    });

    it(`commits ${types.REQUEST_VALUE_STREAMS} and dispatches receiveValueStreamsSuccess with received data on success`, () => {
      return testAction(
        actions.fetchValueStreams,
        null,
        state,
        [{ type: types.REQUEST_VALUE_STREAMS }],
        [
          {
            payload: {
              events: [],
              stages: [],
            },
            type: 'receiveValueStreamsSuccess',
          },
        ],
      );
    });

    describe('with a failing request', () => {
      const resp = { data: {} };
      beforeEach(() => {
        mock.onGet(endpoints.valueStreamData).reply(httpStatusCodes.NOT_FOUND, resp);
      });

      it(`will commit ${types.RECEIVE_VALUE_STREAMS_ERROR}`, () => {
        return testAction(
          actions.fetchValueStreams,
          null,
          state,
          [
            { type: types.REQUEST_VALUE_STREAMS },
            {
              type: types.RECEIVE_VALUE_STREAMS_ERROR,
            },
          ],
          [],
        );
      });
    });

    describe('receiveValueStreamsSuccess', () => {
      it(`commits the ${types.RECEIVE_VALUE_STREAMS_SUCCESS} mutation`, () => {
        return testAction(
          actions.receiveValueStreamsSuccess,
          valueStreams,
          state,
          [
            {
              type: types.RECEIVE_VALUE_STREAMS_SUCCESS,
              payload: valueStreams,
            },
          ],
          [{ type: 'setSelectedValueStream', payload: selectedValueStream.id }],
        );
      });
    });

    describe('with hasCreateMultipleValueStreams disabled', () => {
      beforeEach(() => {
        state = {
          ...state,
          featureFlags: {
            ...state.featureFlags,
            hasCreateMultipleValueStreams: false,
          },
        };
      });

      it(`will dispatch the 'fetchGroupStagesAndEvents' request`, () =>
        testAction(
          actions.fetchValueStreams,
          null,
          state,
          [],
          [{ type: 'fetchGroupStagesAndEvents' }],
        ));
    });
  });
});
