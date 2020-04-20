import { getTasksByTypeData } from '../../../utils';

export const selectedTasksByTypeFilters = (state = {}, _, rootState = {}) => {
  const { selectedLabelIds = [], subject } = state;
  const { selectedGroup, selectedProjectIds = [], startDate, endDate } = rootState;
  return {
    selectedGroup,
    selectedProjectIds,
    startDate,
    endDate,
    selectedLabelIds,
    subject,
  };
};

export const tasksByTypeChartData = ({ data = [] } = {}, _, rootState = {}) => {
  const { startDate = null, endDate = null } = rootState;
  return data.length
    ? getTasksByTypeData({
        data,
        startDate,
        endDate,
      })
    : { groupBy: [], data: [], seriesNames: [] };
};
