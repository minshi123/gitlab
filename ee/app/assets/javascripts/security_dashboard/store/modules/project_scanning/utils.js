/* eslint-disable import/prefer-default-export */
import { getDayDifference } from '~/lib/utils/datetime_utility';

import { PROJECT_SCANNING_DAY_RANGES } from '../../constants';

const isValidDate = date => !Number.isNaN(date.dateFormat());

const dayRangeGroups = () =>
  PROJECT_SCANNING_DAY_RANGES.map(range => ({
    ...range,
    projects: [],
  }));

/**
 * Takes an array of objects and returns an array of date-ranges,
 * which contain all projects that fall under the given range
 *
 * @param projects Array
 * @returns {*}
 */
export const groupByDayRanges = projects =>
  projects.reduce((groups, currentProject) => {
    const lastSuccessfulRun = new Date(currentProject.security_tests_last_successful_run);

    if (!isValidDate(lastSuccessfulRun)) {
      return groups;
    }

    const today = new Date();
    const daysInPast = getDayDifference(lastSuccessfulRun, today);

    groups.forEach(
      group =>
        daysInPast >= group.min && daysInPast < group.max && group.projects.push(currentProject),
    );

    return groups;
  }, dayRangeGroups());
