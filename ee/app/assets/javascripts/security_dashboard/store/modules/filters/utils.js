import { isSubset } from '~/lib/utils/set';
import { ALL } from './constants';

export const isBaseFilterOption = id => id === ALL;

/**
 * Returns whether or not the given state filter has a valid selection,
 * considering its available options.
 * @param {Object} filter The filter from the state to check.
 * @returns boolean
 */
export const hasValidSelection = ({ selection, options }) =>
  isSubset(selection, new Set(options.map(({ id }) => id)));

/**
 * Takes a filter array and a selected payload.
 * It then either adds or removes that option from the appropriate selected filter.
 * With a few extra exceptions around the `ALL` special case.
 * @param {Array} filters the filters to mutate
 * @param {Object} payload
 * @param {String} payload.optionId the ID of the option that was just selected
 * @param {String} payload.filterId the ID of the filter that the selected option belongs to
 * @returns {Array} the mutated filters array
 */
export const setFilter = (filters, { optionIds, filterIds }) => {
  // {filterIds: [ "reportType", "scanner" ], optionId: "CONTAINER_SCANNING"}
  console.log('setFilter', filters, optionIds, filterIds);
  return filters.map(filter => {
    if (filterIds.filter(value => filter.ids.includes(value)).length) {
      const { selection } = filter;

      /* eslint-disable-next-line guard-for-in, no-restricted-syntax */
      for (const optionId of optionIds) {
        if (optionId === ALL) {
          selection.clear();
        } else if (selection.has(optionId)) {
          selection.delete(optionId);
        } else {
          selection.delete(ALL);
          selection.add(optionId);
        }

        if (selection.size === 0) {
          selection.add(ALL);
          break;
        }
      }

      console.log('setFilter: in filter', filter, selection);
      return {
        ...filter,
        selection,
      };
    }
    return filter;
  });
};
