import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import {
  startDate,
  endDate,
  transformedDurationData,
  transformedDurationMedianData,
  durationChartPlottableData,
  durationChartPlottableMedianData,
} from '../../../mock_data';

let state = null;

describe('DurationChart getters', () => {
  describe('durationChartPlottableData', () => {
    it('returns plottable data for selected stages', () => {
      const stateWithDurationData = {
        startDate,
        endDate,
        durationData: transformedDurationData,
      };

      expect(getters.durationChartPlottableData(stateWithDurationData)).toEqual(
        durationChartPlottableData,
      );
    });

    it('returns an empty array if there is no plottable data for the selected stages', () => {
      const stateWithDurationData = {
        startDate,
        endDate,
        durationData: [],
      };

      expect(getters.durationChartPlottableData(stateWithDurationData)).toEqual([]);
    });
  });

  describe('durationChartPlottableMedianData', () => {
    it('returns plottable median data for selected stages', () => {
      const stateWithDurationMedianData = {
        startDate,
        endDate,
        durationMedianData: transformedDurationMedianData,
      };

      expect(getters.durationChartMedianData(stateWithDurationMedianData)).toEqual(
        durationChartPlottableMedianData,
      );
    });

    it('returns an empty array if there is no plottable median data for the selected stages', () => {
      const stateWithDurationMedianData = {
        startDate,
        endDate,
        durationMedianData: [],
      };

      expect(getters.durationChartMedianData(stateWithDurationMedianData)).toEqual([]);
    });
  });
});
