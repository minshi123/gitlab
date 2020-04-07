/**
 * @param {String} queryLabel - Default query label for chart
 * @param {Object} metricAttributes - Default metric attribute values (e.g. method, instance)
 * @returns {String || Boolean} The formatted query label or a false flag
 */
function singleAttributeLabel(queryLabel, metricAttributes) {
  if (!queryLabel) return false;
  const relevantAttribute = queryLabel.toLowerCase().replace(' ', '_');
  const value = metricAttributes[relevantAttribute];
  if (!value) return false;
  return `${queryLabel}: ${value}`;
}

/**
 * @param {String} queryLabel - Default query label for chart
 * @param {Object} metricAttributes - Default metric attribute values (e.g. method, instance)
 * @returns {String || Boolean} The formatted query label or a false flag
 */
function templatedLabel(queryLabel, metricAttributes) {
  if (!queryLabel) return false;
  let label = queryLabel;
  Object.keys(metricAttributes).forEach(templateVar => {
    const value = metricAttributes[templateVar];
    const regex = new RegExp(`{{\\s*${templateVar}\\s*}}`, 'g');

    label = label.replace(regex, value);
  });

  return label;
}

/**
 * @param {Object} metricAttributes - Default metric attribute values (e.g. method, instance)
 * @returns {String || Boolean} The formatted query label or a false flag
 */
function multiMetricLabel(metricAttributes) {
  if (!Object.keys(metricAttributes).length) return false;
  const attributePairs = [];
  Object.keys(metricAttributes).forEach(templateVar => {
    const value = metricAttributes[templateVar];
    attributePairs.push(`${templateVar}: ${value}`);
  });

  return attributePairs.join(', ');
}

/**
 * @param {String} queryLabel - Default query label for chart
 * @param {Object} metricAttributes - Default metric attribute values (e.g. method, instance)
 * @returns {String} The formatted query label
 */
const getSeriesLabel = (queryLabel, metricAttributes) =>
  singleAttributeLabel(queryLabel, metricAttributes) ||
  templatedLabel(queryLabel, metricAttributes) ||
  multiMetricLabel(metricAttributes) ||
  `${queryLabel}`;

/**
 * @param {Array} queryResults - Array of Result objects
 * @param {Object} defaultConfig - Default chart config values (e.g. lineStyle, name)
 * @returns {Array} The formatted values
 */
// eslint-disable-next-line import/prefer-default-export
export const makeDataSeries = (queryResults, defaultConfig) =>
  queryResults
    .map(result => {
      // NaN values may disrupt avg., max. & min. calculations in the legend, filter them out
      const data = result.values.filter(([, value]) => !Number.isNaN(value));
      if (!data.length) {
        return null;
      }
      const series = { data };
      return {
        ...defaultConfig,
        ...series,
        name: getSeriesLabel(defaultConfig.name, result.metric),
      };
    })
    .filter(series => series !== null);
