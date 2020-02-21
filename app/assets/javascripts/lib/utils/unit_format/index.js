import { suffixFormatter, scaledSIFormatter, numberFormatter } from './formatter_factory';

export const SUPPORTED_FORMATS = {
  // Number
  number: 'number',

  // Duration
  seconds: 'seconds',
  miliseconds: 'miliseconds',

  // Digital
  bytes: 'bytes',
  kilobytes: 'kilobytes',
  megabytes: 'megabytes',
  gigabytes: 'gigabytes',
  terabytes: 'terabytes',
  petabytes: 'petabytes',
};

export const getFormatter = (format = 'number') => {
  // Number
  if (format === SUPPORTED_FORMATS.number) {
    return numberFormatter();
  }

  // Durations
  if (format === SUPPORTED_FORMATS.seconds) {
    return suffixFormatter('s');
  }
  if (format === SUPPORTED_FORMATS.miliseconds) {
    return suffixFormatter('ms');
  }

  // Digital
  if (format === SUPPORTED_FORMATS.bytes) {
    return scaledSIFormatter('B');
  }
  if (format === SUPPORTED_FORMATS.kilobytes) {
    return scaledSIFormatter('B', 1);
  }
  if (format === SUPPORTED_FORMATS.megabytes) {
    return scaledSIFormatter('B', 2);
  }
  if (format === SUPPORTED_FORMATS.gigabytes) {
    return scaledSIFormatter('B', 3);
  }
  if (format === SUPPORTED_FORMATS.terabytes) {
    return scaledSIFormatter('B', 4);
  }
  if (format === SUPPORTED_FORMATS.petabytes) {
    return scaledSIFormatter('B', 5);
  }
  // Fail so client library addresses issue
  return () => 'N/A';
};
