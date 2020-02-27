import { getFormatter, SUPPORTED_FORMATS } from '~/lib/utils/unit_format';

describe('unit_format', () => {
  describe('when a supported format is provided, the returned function formats', () => {
    it('numbers, by default', () => {
      expect(getFormatter()(1)).toEqual('1');
    });

    it('numbers', () => {
      const formatNumber = getFormatter(SUPPORTED_FORMATS.number);

      expect(formatNumber(1)).toEqual('1');
      expect(formatNumber(100)).toEqual('100');
      expect(formatNumber(1000)).toEqual('1,000');
      expect(formatNumber(10000)).toEqual('10,000');
      expect(formatNumber(1000000)).toEqual('1,000,000');
    });

    it('percent', () => {
      const formatPercent = getFormatter(SUPPORTED_FORMATS.percent);

      expect(formatPercent(1)).toEqual('100%');
      expect(formatPercent(1, 2)).toEqual('100.00%');

      expect(formatPercent(0.1)).toEqual('10%');
      expect(formatPercent(0.5)).toEqual('50%');

      expect(formatPercent(0.888888)).toEqual('89%');
      expect(formatPercent(0.888888, 2)).toEqual('88.89%');
      expect(formatPercent(0.888888, 5)).toEqual('88.88880%');

      expect(formatPercent(2)).toEqual('200%');
      expect(formatPercent(10)).toEqual('1,000%');
    });

    it('percentunit', () => {
      const formatPercentHundred = getFormatter(SUPPORTED_FORMATS.percentHundred);

      expect(formatPercentHundred(1)).toEqual('1%');
      expect(formatPercentHundred(1, 2)).toEqual('1.00%');

      expect(formatPercentHundred(88.8888)).toEqual('89%');
      expect(formatPercentHundred(88.8888, 2)).toEqual('88.89%');
      expect(formatPercentHundred(88.8888, 5)).toEqual('88.88880%');

      expect(formatPercentHundred(100)).toEqual('100%');
      expect(formatPercentHundred(100, 2)).toEqual('100.00%');

      expect(formatPercentHundred(200)).toEqual('200%');
      expect(formatPercentHundred(1000)).toEqual('1,000%');
    });

    it('seconds', () => {
      expect(getFormatter(SUPPORTED_FORMATS.seconds)(1)).toEqual('1s');
    });

    it('milliseconds', () => {
      const formatMilliseconds = getFormatter(SUPPORTED_FORMATS.milliseconds);

      expect(formatMilliseconds(1)).toEqual('1ms');
      expect(formatMilliseconds(100)).toEqual('100ms');
      expect(formatMilliseconds(1000)).toEqual('1,000ms');
      expect(formatMilliseconds(10000)).toEqual('10,000ms');
      expect(formatMilliseconds(1000000)).toEqual('1,000,000ms');
    });

    it('decimalBytes', () => {
      const formatDecimalBytes = getFormatter(SUPPORTED_FORMATS.decimalBytes);

      expect(formatDecimalBytes(1)).toEqual('1B');
      expect(formatDecimalBytes(1, 1)).toEqual('1.0B');

      expect(formatDecimalBytes(10)).toEqual('10B');
      expect(formatDecimalBytes(10 ** 2)).toEqual('100B');
      expect(formatDecimalBytes(10 ** 3)).toEqual('1kB');
      expect(formatDecimalBytes(10 ** 4)).toEqual('10kB');
      expect(formatDecimalBytes(10 ** 5)).toEqual('100kB');
      expect(formatDecimalBytes(10 ** 6)).toEqual('1MB');
      expect(formatDecimalBytes(10 ** 7)).toEqual('10MB');
      expect(formatDecimalBytes(10 ** 8)).toEqual('100MB');
      expect(formatDecimalBytes(10 ** 9)).toEqual('1GB');
      expect(formatDecimalBytes(10 ** 10)).toEqual('10GB');
      expect(formatDecimalBytes(10 ** 11)).toEqual('100GB');
    });

    it('kilobytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.kilobytes)(1)).toEqual('1kB');
      expect(getFormatter(SUPPORTED_FORMATS.kilobytes)(1, 1)).toEqual('1.0kB');
    });

    it('megabytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.megabytes)(1)).toEqual('1MB');
      expect(getFormatter(SUPPORTED_FORMATS.megabytes)(1, 1)).toEqual('1.0MB');
    });

    it('gigabytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.gigabytes)(1)).toEqual('1GB');
      expect(getFormatter(SUPPORTED_FORMATS.gigabytes)(1, 1)).toEqual('1.0GB');
    });

    it('terabytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.terabytes)(1)).toEqual('1TB');
      expect(getFormatter(SUPPORTED_FORMATS.terabytes)(1, 1)).toEqual('1.0TB');
    });

    it('petabytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.petabytes)(1)).toEqual('1PB');
      expect(getFormatter(SUPPORTED_FORMATS.petabytes)(1, 1)).toEqual('1.0PB');
    });

    it('bytes', () => {
      const formatBytes = getFormatter(SUPPORTED_FORMATS.bytes);

      expect(formatBytes(1)).toEqual('1B');
      expect(formatBytes(1, 1)).toEqual('1.0B');

      expect(formatBytes(10)).toEqual('10B');
      expect(formatBytes(100)).toEqual('100B');
      expect(formatBytes(1000)).toEqual('1,000B');

      expect(formatBytes(1 * 1024)).toEqual('1KiB');
      expect(formatBytes(1 * 1024 ** 2)).toEqual('1MiB');
      expect(formatBytes(1 * 1024 ** 3)).toEqual('1GiB');
    });

    it('kibibytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.kibibytes)(1)).toEqual('1KiB');
      expect(getFormatter(SUPPORTED_FORMATS.kibibytes)(1, 1)).toEqual('1.0KiB');
    });

    it('mebibytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.mebibytes)(1)).toEqual('1MiB');
      expect(getFormatter(SUPPORTED_FORMATS.mebibytes)(1, 1)).toEqual('1.0MiB');
    });

    it('gibibytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.gibibytes)(1)).toEqual('1GiB');
      expect(getFormatter(SUPPORTED_FORMATS.gibibytes)(1, 1)).toEqual('1.0GiB');
    });

    it('tebibytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.tebibytes)(1)).toEqual('1TiB');
      expect(getFormatter(SUPPORTED_FORMATS.tebibytes)(1, 1)).toEqual('1.0TiB');
    });

    it('pebibytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.pebibytes)(1)).toEqual('1PiB');
      expect(getFormatter(SUPPORTED_FORMATS.pebibytes)(1, 1)).toEqual('1.0PiB');
    });
  });

  describe('when get formatter format is incorrect', () => {
    it('formatter fails', () => {
      expect(() => getFormatter('not-supported')(1)).toThrow();
    });
  });
});
