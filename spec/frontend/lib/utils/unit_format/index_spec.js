import { getFormatter, SUPPORTED_FORMATS } from '~/lib/utils/unit_format';

describe('unit_format', () => {
  describe('when a supported format is provided, the returned function formats', () => {
    it('numbers, by default', () => {
      expect(getFormatter()(1)).toEqual('1');
    });

    it('numbers', () => {
      expect(getFormatter(SUPPORTED_FORMATS.number)(1)).toEqual('1');
    });

    it('seconds', () => {
      expect(getFormatter(SUPPORTED_FORMATS.seconds)(1)).toEqual('1s');
    });

    it('miliseconds', () => {
      expect(getFormatter(SUPPORTED_FORMATS.miliseconds)(1)).toEqual('1ms');
    });

    it('bytes', () => {
      expect(getFormatter(SUPPORTED_FORMATS.bytes)(1)).toEqual('1B');
      expect(getFormatter(SUPPORTED_FORMATS.bytes)(1, 1)).toEqual('1.0B');
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
  });

  describe('when get formatter format is incorrect', () => {
    it('formatter fails', () => {
      expect(getFormatter('not-supported')(1)).toEqual('N/A');
    });
  });
});
