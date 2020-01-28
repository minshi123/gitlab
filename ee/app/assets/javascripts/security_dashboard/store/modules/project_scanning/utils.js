/* eslint-disable import/prefer-default-export */
import { getDayDifference } from '~/lib/utils/datetime_utility';

import { PROJECT_SCANNING_DAY_RANGES } from '../../constants';

const isValidDate = date => !Number.isNaN(date.dateFormat());

const dayRangeGroups = () =>
  PROJECT_SCANNING_DAY_RANGES.map(range => ({
    ...range,
    projects: [],
  }));

export const groupsTwo = projects =>
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
