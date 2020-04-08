// TODO: move these closer
import { getDurationChartData, getDurationChartMedianData } from '../../../utils';

export const durationChartPlottableData = state => {
  const { durationData, startDate, endDate } = state;
  const selectedStagesDurationData = durationData.filter(stage => stage.selected);
  const plottableData = getDurationChartData(selectedStagesDurationData, startDate, endDate);

  return plottableData.length ? plottableData : [];
};

export const durationChartMedianData = state => {
  const { durationMedianData, startDate, endDate } = state;
  const selectedStagesDurationMedianData = durationMedianData.filter(stage => stage.selected);
  const plottableData = getDurationChartMedianData(
    selectedStagesDurationMedianData,
    startDate,
    endDate,
  );

  return plottableData.length ? plottableData : [];
};
