import dateFormat from 'dateformat';

export const timezoneOptions = {
  local: 'local',
  utc: 'utc',
};

export const masks = {
  isoTime: 'isoTime',
  default: 'dd mmm yyyy, h:MMTT',
};

export const timestampToISODate = timestamp => new Date(timestamp).toISOString();

/**
 * Convenience wrapper of dateFormat with Monitoring
 * stage masks and settings.
 *
 * @param {Date|String|Number} date
 * @param {String} mask
 * @param {Object} Options, supports `timezone`
 */
export const formatDate = (date, mask = masks.default, options = {}) => {
  const { timezone = timezoneOptions.local } = options;

  if (timezone === timezoneOptions.utc) {
    return dateFormat(date, mask, true);
  }
  return dateFormat(date, mask, false);
};
