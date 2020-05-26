import dateformat from 'dateformat';
import { __ } from '~/locale';

/**
 * Default time ranges for the date picker.
 * @see app/assets/javascripts/lib/utils/datetime_range.js
 */
export const defaultTimeRanges = [
  {
    duration: { seconds: 60 * 30 },
    label: __('30 minutes'),
  },
  {
    duration: { seconds: 60 * 60 * 3 },
    label: __('3 hours'),
  },
  {
    duration: { seconds: 60 * 60 * 8 },
    label: __('8 hours'),
    default: true,
  },
  {
    duration: { seconds: 60 * 60 * 24 * 1 },
    label: __('1 day'),
  },
];

export const defaultTimeRange = defaultTimeRanges.find(tr => tr.default);

export const dateFormats = {
  stringDate: 'yyyy-mm-dd HH:MM:ss',
};

/**
 * The URL params start and end need to be validated
 * before passing them down to other components.
 *
 * @param {string} dateString
 * @returns true if the string is a valid date, false otherwise
 */
export const isValidDate = dateString => {
  try {
    // dateformat throws error that can be caught.
    // This is better than using `new Date()`
    if (dateString && dateString.trim()) {
      dateformat(dateString, 'isoDateTime');
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
};

/**
 * Convert the input in Time picker component to ISO date.
 *
 * If the string is already in UTC, utc should be marked as false.
 *
 * @param {string} val
 * @returns {string}
 */
export const stringToISODate = (val, utc = false) => {
  let date = new Date(val.replace(/-/g, '/'));
  if (utc) {
    // Strip timezone from date, by using a string and 'Z'
    date = dateformat(date, "yyyy-mm-dd'T'HH:MM:ss'Z'");
  }
  return dateformat(date, 'isoUtcDateTime');
};

/**
 * Convert the ISO date received from the URL to string
 * for the Time picker component.
 *
 * @param {Date} date
 * @returns {string}
 */
export const formatIsoDate = (date, utc = false) => dateformat(date, dateFormats.stringDate, utc);

export const truncateZerosInDateTime = datetime => datetime.replace(' 00:00:00', '');

export default {};
