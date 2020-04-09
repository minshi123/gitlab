import mutations from 'ee/analytics/cycle_analytics/store/mutations';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';

import { transformedDurationData, transformedDurationMedianData } from '../../../mock_data';

let state = null;

describe('Cycle analytics mutations', () => {
  beforeEach(() => {
    state = {};
  });

  afterEach(() => {
    state = null;
  });

  it.each`
    mutation                              | stateKey                              | value
    ${types.REQUEST_DURATION_DATA}        | ${'isLoadingDurationChart'}           | ${true}
    ${types.RECEIVE_DURATION_DATA_ERROR}  | ${'isLoadingDurationChart'}           | ${false}
    ${types.REQUEST_DURATION_MEDIAN_DATA} | ${'isLoadingDurationChartMedianData'} | ${true}
  `('$mutation will set $stateKey=$value', ({ mutation, stateKey, value }) => {
    mutations[mutation](state);

    expect(state[stateKey]).toEqual(value);
  });

  it.each`
    mutation                                       | payload                                                                                                                 | expectedState
    ${types.UPDATE_SELECTED_DURATION_CHART_STAGES} | ${{ updatedDurationStageData: transformedDurationData, updatedDurationStageMedianData: transformedDurationMedianData }} | ${{ durationData: transformedDurationData, durationMedianData: transformedDurationMedianData }}
  `(
    '$mutation with payload $payload will update state with $expectedState',
    ({ mutation, payload, expectedState }) => {
      state = {
        selectedGroup: { fullPath: 'rad-stage' },
      };
      mutations[mutation](state, payload);

      expect(state).toMatchObject(expectedState);
    },
  );

  describe(`${types.RECEIVE_DURATION_DATA_SUCCESS}`, () => {
    it('sets the data correctly and falsifies isLoadingDurationChart', () => {
      const stateWithData = {
        isLoadingDurationChart: true,
        durationData: [['something', 'random']],
      };

      mutations[types.RECEIVE_DURATION_DATA_SUCCESS](stateWithData, transformedDurationData);

      expect(stateWithData.isLoadingDurationChart).toBe(false);
      expect(stateWithData.durationData).toBe(transformedDurationData);
    });
  });

  describe(`${types.RECEIVE_DURATION_MEDIAN_DATA_SUCCESS}`, () => {
    it('sets the data correctly and falsifies isLoadingDurationChartMedianData', () => {
      const stateWithData = {
        isLoadingDurationChartMedianData: true,
        durationMedianData: [['something', 'random']],
      };

      mutations[types.RECEIVE_DURATION_MEDIAN_DATA_SUCCESS](
        stateWithData,
        transformedDurationMedianData,
      );

      expect(stateWithData.isLoadingDurationChartMedianData).toBe(false);
      expect(stateWithData.durationMedianData).toBe(transformedDurationMedianData);
    });
  });

  describe(`${types.RECEIVE_DURATION_MEDIAN_DATA_ERROR}`, () => {
    it('falsifies isLoadingDurationChartMedianData and sets durationMedianData to an empty array', () => {
      const stateWithData = {
        isLoadingDurationChartMedianData: true,
        durationMedianData: [['something', 'random']],
      };

      mutations[types.RECEIVE_DURATION_MEDIAN_DATA_ERROR](stateWithData);

      expect(stateWithData.isLoadingDurationChartMedianData).toBe(false);
      expect(stateWithData.durationMedianData).toStrictEqual([]);
    });
  });
});
