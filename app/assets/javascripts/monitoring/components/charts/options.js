import { getFormatter } from '~/lib/utils/unit_format';

// General Options

export const defaultFormat = 'number';

// Axis defaults

const maxDataAxisTickLength = 8;

const axisTickPrecision = 2;

/**
 * Converts .yml parameters to echart axis options
 * @param {Object} param - Dashboard .yml definition options
 */
export const getDataAxisOptions = ({
  format = defaultFormat,
  precision = axisTickPrecision,
  name,
}) => {
  const formatter = getFormatter(format);

  return {
    name,
    nameLocation: 'center', // same as gitlab-ui's default
    scale: true,
    axisLabel: {
      formatter: num => formatter(num, precision, maxDataAxisTickLength),
    },
  };
};

/**
 * Converts .yml parameters to echart axis options
 * @param {Object} param - Dashboard .yml definition options
 */
export const getYAxisOptions = ({
  format = defaultFormat,
  precision = axisTickPrecision,
  name,
}) => {
  return {
    nameGap: 63,
    scale: true,
    boundaryGap: [0.1, 0.1],

    ...getDataAxisOptions({
      format,
      precision,
      name,
    }),
  };
};

// Tooltip defaults

const tooltipPrecision = 3;

export const getTooltipFormatter = ({ format = defaultFormat, precision = tooltipPrecision }) => {
  const tooltFormatter = getFormatter(format);
  return num => {
    return tooltFormatter(num, precision);
  };
};
