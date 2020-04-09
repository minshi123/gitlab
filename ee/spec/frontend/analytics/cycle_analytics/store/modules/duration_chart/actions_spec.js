import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import * as actions from 'ee/analytics/cycle_analytics/store/actions';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';
import {
  group,
  allowedStages as stages,
  startDate,
  endDate,
  rawDurationData,
  rawDurationMedianData,
  transformedDurationData,
  transformedDurationMedianData,
  endpoints,
} from '../../../mock_data';
import { shouldFlashAMessage } from '../../../helpers';

const selectedGroup = { fullPath: group.path };

describe('DurationChart actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = {
      startDate,
      endDate,
      stages: [],
      featureFlags: {
        hasDurationChart: true,
        hasTasksByTypeChart: true,
        hasDurationChartMedian: true,
      },
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    state = { ...state, selectedGroup: null };
  });

  describe('fetchDurationData', () => {
    beforeEach(() => {
      mock.onGet(endpoints.durationData).reply(200, [...rawDurationData]);
    });

    it("dispatches the 'receiveDurationDataSuccess' action on success", done => {
      const stateWithStages = {
        ...state,
        stages: [stages[0], stages[1]],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationData({
          dispatch,
          state: stateWithStages,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenCalledWith(
            'receiveDurationDataSuccess',
            transformedDurationData,
          );
          done();
        })
        .catch(done.fail);
    });

    it("dispatches the 'requestDurationData' action", done => {
      const stateWithStages = {
        ...state,
        stages: [stages[0], stages[1]],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationData({
          dispatch,
          state: stateWithStages,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenNthCalledWith(1, 'requestDurationData');
          done();
        })
        .catch(done.fail);
    });

    it("dispatches the 'receiveDurationDataError' action when there is an error", done => {
      const brokenState = {
        ...state,
        stages: [
          {
            id: 'oops',
          },
        ],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationData({
          dispatch,
          state: brokenState,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenCalledWith('receiveDurationDataError');
          done();
        })
        .catch(done.fail);
    });
  });

  describe('receiveDurationDataSuccess', () => {
    describe('with hasDurationChartMedian feature flag enabled', () => {
      it('commits the transformed duration data and dispatches fetchDurationMedianData', () => {
        testAction(
          actions.receiveDurationDataSuccess,
          transformedDurationData,
          state,
          [
            {
              type: types.RECEIVE_DURATION_DATA_SUCCESS,
              payload: transformedDurationData,
            },
          ],
          [
            {
              type: 'fetchDurationMedianData',
            },
          ],
        );
      });
    });

    describe('with hasDurationChartMedian feature flag disabled', () => {
      const disabledState = {
        ...state,
        featureFlags: {
          hasDurationChartMedian: false,
        },
      };

      it('commits the transformed duration data', () => {
        testAction(
          actions.receiveDurationDataSuccess,
          transformedDurationData,
          disabledState,
          [
            {
              type: types.RECEIVE_DURATION_DATA_SUCCESS,
              payload: transformedDurationData,
            },
          ],
          [],
        );
      });
    });
  });

  describe('receiveDurationDataError', () => {
    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
    });

    it("commits the 'RECEIVE_DURATION_DATA_ERROR' mutation", () => {
      testAction(
        actions.receiveDurationDataError,
        {},
        state,
        [
          {
            type: types.RECEIVE_DURATION_DATA_ERROR,
          },
        ],
        [],
      );
    });

    it('will flash an error', () => {
      actions.receiveDurationDataError({
        commit: () => {},
      });

      shouldFlashAMessage(
        'There was an error while fetching value stream analytics duration data.',
      );
    });
  });

  describe('updateSelectedDurationChartStages', () => {
    it("commits the 'UPDATE_SELECTED_DURATION_CHART_STAGES' mutation with all the selected stages in the duration data", () => {
      const stateWithDurationData = {
        ...state,
        durationData: transformedDurationData,
        durationMedianData: transformedDurationMedianData,
      };

      testAction(
        actions.updateSelectedDurationChartStages,
        [...stages],
        stateWithDurationData,
        [
          {
            type: types.UPDATE_SELECTED_DURATION_CHART_STAGES,
            payload: {
              updatedDurationStageData: transformedDurationData,
              updatedDurationStageMedianData: transformedDurationMedianData,
            },
          },
        ],
        [],
      );
    });

    it("commits the 'UPDATE_SELECTED_DURATION_CHART_STAGES' mutation with all the selected and deselected stages in the duration data", () => {
      const stateWithDurationData = {
        ...state,
        durationData: transformedDurationData,
        durationMedianData: transformedDurationMedianData,
      };

      testAction(
        actions.updateSelectedDurationChartStages,
        [stages[0]],
        stateWithDurationData,
        [
          {
            type: types.UPDATE_SELECTED_DURATION_CHART_STAGES,
            payload: {
              updatedDurationStageData: [
                transformedDurationData[0],
                {
                  ...transformedDurationData[1],
                  selected: false,
                },
              ],
              updatedDurationStageMedianData: [
                transformedDurationMedianData[0],
                {
                  ...transformedDurationMedianData[1],
                  selected: false,
                },
              ],
            },
          },
        ],
        [],
      );
    });

    it("commits the 'UPDATE_SELECTED_DURATION_CHART_STAGES' mutation with all deselected stages in the duration data", () => {
      const stateWithDurationData = {
        ...state,
        durationData: transformedDurationData,
        durationMedianData: transformedDurationMedianData,
      };

      testAction(
        actions.updateSelectedDurationChartStages,
        [],
        stateWithDurationData,
        [
          {
            type: types.UPDATE_SELECTED_DURATION_CHART_STAGES,
            payload: {
              updatedDurationStageData: [
                {
                  ...transformedDurationData[0],
                  selected: false,
                },
                {
                  ...transformedDurationData[1],
                  selected: false,
                },
              ],
              updatedDurationStageMedianData: [
                {
                  ...transformedDurationMedianData[0],
                  selected: false,
                },
                {
                  ...transformedDurationMedianData[1],
                  selected: false,
                },
              ],
            },
          },
        ],
        [],
      );
    });
  });

  describe('fetchDurationMedianData', () => {
    beforeEach(() => {
      mock.onGet(endpoints.durationData).reply(200, [...rawDurationMedianData]);
    });

    it('dispatches requestDurationMedianData when called', done => {
      const stateWithStages = {
        ...state,
        stages: [stages[0], stages[1]],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationMedianData({
          dispatch,
          state: stateWithStages,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenNthCalledWith(1, 'requestDurationMedianData');
          done();
        })
        .catch(done.fail);
    });

    it('dispatches the receiveDurationMedianDataSuccess action on success', done => {
      const stateWithStages = {
        ...state,
        stages: [stages[0], stages[1]],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationMedianData({
          dispatch,
          state: stateWithStages,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenCalledWith(
            'receiveDurationMedianDataSuccess',
            transformedDurationMedianData,
          );
          done();
        })
        .catch(done.fail);
    });

    it('dispatches the receiveDurationMedianDataError action when there is an error', done => {
      const brokenState = {
        ...state,
        stages: [
          {
            id: 'oops',
          },
        ],
        selectedGroup,
      };
      const dispatch = jest.fn();

      actions
        .fetchDurationMedianData({
          dispatch,
          state: brokenState,
          getters,
        })
        .then(() => {
          expect(dispatch).toHaveBeenCalledWith('receiveDurationMedianDataError');
          done();
        })
        .catch(done.fail);
    });
  });

  describe('receiveDurationMedianDataSuccess', () => {
    it('commits the transformed duration median data', done => {
      testAction(
        actions.receiveDurationMedianDataSuccess,
        transformedDurationMedianData,
        state,
        [
          {
            type: types.RECEIVE_DURATION_MEDIAN_DATA_SUCCESS,
            payload: transformedDurationMedianData,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('receiveDurationMedianDataError', () => {
    beforeEach(() => {
      setFixtures('<div class="flash-container"></div>');
    });

    it("commits the 'RECEIVE_DURATION_MEDIAN_DATA_ERROR' mutation", () => {
      testAction(
        actions.receiveDurationMedianDataError,
        {},
        state,
        [
          {
            type: types.RECEIVE_DURATION_MEDIAN_DATA_ERROR,
          },
        ],
        [],
      );
    });

    it('will flash an error', () => {
      actions.receiveDurationMedianDataError({
        commit: () => {},
      });

      shouldFlashAMessage(
        'There was an error while fetching value stream analytics duration median data.',
      );
    });
  });
});
