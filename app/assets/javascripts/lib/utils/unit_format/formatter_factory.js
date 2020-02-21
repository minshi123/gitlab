function formatFixedPoint(value, { fractionDigits = undefined, maxLength = undefined }) {
  if (value === null) {
    return '';
  }

  const formatted = value.toLocaleString(undefined, {
    minimumFractionDigits: fractionDigits,
    maximumFractionDigits: fractionDigits,
  });

  if (maxLength !== undefined && formatted.length > maxLength) {
    return value.toExponential(2);
  }
  return formatted;
}

// Formatter which scales the unit string geometrically according to the given
// numeric factor. Repeatedly scales the value down by the factor until it is
// less than the factor in magnitude, or the end of the array is reached.
const scaledFormatter = (units, factor = 1000) => {
  return (value, fractionDigits) => {
    if (value === null) {
      return '';
    }
    if (
      value === Number.NEGATIVE_INFINITY ||
      value === Number.POSITIVE_INFINITY ||
      Number.isNaN(value)
    ) {
      return value.toLocaleString(undefined);
    }

    let num = value;
    let scale = 0;
    const limit = units.length;

    while (Math.abs(num) >= factor) {
      scale += 1;
      num /= factor;

      if (scale >= limit) {
        return 'NA';
      }
    }

    const unit = units[scale];

    return `${formatFixedPoint(num, { fractionDigits })}${unit}`;
  };
};

export const numberFormatter = () => {
  return (value, fractionDigits, maxLength) => {
    return `${formatFixedPoint(value, { fractionDigits, maxLength })}`;
  };
};

export const suffixFormatter = (unit = '') => {
  return (value, fractionDigits, maxLength) => {
    const length = maxLength !== undefined ? maxLength - unit.length : undefined;
    return `${formatFixedPoint(value, { fractionDigits, maxLength: length })}${unit}`;
  };
};

export const scaledSIFormatter = (unit = '', prefixOffset = 0) => {
  const fractional = ['y', 'z', 'a', 'f', 'p', 'n', 'µ', 'm'];
  const multiplicative = ['k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y'];
  const symbols = [...fractional, '', ...multiplicative];

  const units = symbols.slice(fractional.length + prefixOffset).map(prefix => {
    return `${prefix}${unit}`;
  });

  if (!units.length) {
    // eslint-disable-next-line @gitlab/i18n/no-non-i18n-strings
    throw new RangeError('The unit cannot be converted, please try a different scale');
  }

  return scaledFormatter(units);
};
