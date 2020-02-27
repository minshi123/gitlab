import {
  numberFormatter,
  suffixFormatter,
  scaledSIFormatter,
  scaledBinaryFormatter,
} from '~/lib/utils/unit_format/formatter_factory';

describe('unit_format/formatter_factory', () => {
  describe('numberFormatter', () => {
    let formatNumber;
    beforeEach(() => {
      formatNumber = numberFormatter();
    });

    it('formats a integer', () => {
      expect(formatNumber(1)).toEqual('1');
      expect(formatNumber(100)).toEqual('100');
      expect(formatNumber(1000)).toEqual('1,000');
      expect(formatNumber(10000)).toEqual('10,000');
      expect(formatNumber(1000000)).toEqual('1,000,000');
    });

    it('formats a floating point number', () => {
      expect(formatNumber(0.1)).toEqual('0.1');
      expect(formatNumber(0.1, 0)).toEqual('0');
      expect(formatNumber(0.1, 2)).toEqual('0.10');
      expect(formatNumber(0.1, 3)).toEqual('0.100');

      expect(formatNumber(12.345)).toEqual('12.345');
      expect(formatNumber(12.345, 2)).toEqual('12.35');
      expect(formatNumber(12.345, 4)).toEqual('12.3450');
    });

    it('formats a large integer with a length limit', () => {
      expect(formatNumber(10 ** 7, undefined)).toEqual('10,000,000');
      expect(formatNumber(10 ** 7, undefined, 9)).toEqual('1.00e+7');
      expect(formatNumber(10 ** 7, undefined, 10)).toEqual('10,000,000');
    });
  });

  describe('suffixFormatter', () => {
    let formatSuffix;
    beforeEach(() => {
      formatSuffix = suffixFormatter('pop.', undefined);
    });

    it('formats a integer', () => {
      expect(formatSuffix(1)).toEqual('1pop.');
      expect(formatSuffix(100)).toEqual('100pop.');
      expect(formatSuffix(1000)).toEqual('1,000pop.');
      expect(formatSuffix(10000)).toEqual('10,000pop.');
      expect(formatSuffix(1000000)).toEqual('1,000,000pop.');
    });

    it('formats a floating point number', () => {
      expect(formatSuffix(0.1)).toEqual('0.1pop.');
      expect(formatSuffix(0.1, 0)).toEqual('0pop.');
      expect(formatSuffix(0.1, 2)).toEqual('0.10pop.');
      expect(formatSuffix(0.1, 3)).toEqual('0.100pop.');

      expect(formatSuffix(12.345)).toEqual('12.345pop.');
      expect(formatSuffix(12.345, 2)).toEqual('12.35pop.');
      expect(formatSuffix(12.345, 4)).toEqual('12.3450pop.');
    });

    it('formats a negative integer', () => {
      expect(formatSuffix(-1)).toEqual('-1pop.');
      expect(formatSuffix(-100)).toEqual('-100pop.');
      expect(formatSuffix(-1000)).toEqual('-1,000pop.');
      expect(formatSuffix(-10000)).toEqual('-10,000pop.');
      expect(formatSuffix(-1000000)).toEqual('-1,000,000pop.');
    });

    it('formats a floating point nugative number', () => {
      expect(formatSuffix(-0.1)).toEqual('-0.1pop.');
      expect(formatSuffix(-0.1, 0)).toEqual('-0pop.');
      expect(formatSuffix(-0.1, 2)).toEqual('-0.10pop.');
      expect(formatSuffix(-0.1, 3)).toEqual('-0.100pop.');

      expect(formatSuffix(-12.345)).toEqual('-12.345pop.');
      expect(formatSuffix(-12.345, 2)).toEqual('-12.35pop.');
      expect(formatSuffix(-12.345, 4)).toEqual('-12.3450pop.');
    });

    it('formats a large integer', () => {
      expect(formatSuffix(10 ** 7)).toEqual('10,000,000pop.');
      expect(formatSuffix(10 ** 10)).toEqual('10,000,000,000pop.');
    });

    it('formats a large integer with a length limit', () => {
      expect(formatSuffix(10 ** 7, undefined, 10)).toEqual('1.00e+7pop.');
      expect(formatSuffix(10 ** 10, undefined, 10)).toEqual('1.00e+10pop.');
    });
  });

  describe('scaledSIFormatter', () => {
    describe('scaled format', () => {
      let formatGibibytes;

      beforeEach(() => {
        formatGibibytes = scaledSIFormatter('B');
      });

      it('formats bytes', () => {
        expect(formatGibibytes(12.345)).toEqual('12.345B');
        expect(formatGibibytes(12.345, 0)).toEqual('12B');
        expect(formatGibibytes(12.345, 1)).toEqual('12.3B');
        expect(formatGibibytes(12.345, 2)).toEqual('12.35B');
      });

      it('formats bytes in a decimal scale', () => {
        expect(formatGibibytes(1)).toEqual('1B');
        expect(formatGibibytes(10)).toEqual('10B');
        expect(formatGibibytes(10 ** 2)).toEqual('100B');
        expect(formatGibibytes(10 ** 3)).toEqual('1kB');
        expect(formatGibibytes(10 ** 4)).toEqual('10kB');
        expect(formatGibibytes(10 ** 5)).toEqual('100kB');
        expect(formatGibibytes(10 ** 6)).toEqual('1MB');
        expect(formatGibibytes(10 ** 7)).toEqual('10MB');
        expect(formatGibibytes(10 ** 8)).toEqual('100MB');
        expect(formatGibibytes(10 ** 9)).toEqual('1GB');
        expect(formatGibibytes(10 ** 10)).toEqual('10GB');
        expect(formatGibibytes(10 ** 11)).toEqual('100GB');
      });
    });

    describe('scaled format with offset', () => {
      let formatGigaBytes;

      beforeEach(() => {
        // formats gigabytes
        formatGigaBytes = scaledSIFormatter('B', 3);
      });

      it('formats floating point numbers', () => {
        expect(formatGigaBytes(12.345)).toEqual('12.345GB');
        expect(formatGigaBytes(12.345, 0)).toEqual('12GB');
        expect(formatGigaBytes(12.345, 1)).toEqual('12.3GB');
        expect(formatGigaBytes(12.345, 2)).toEqual('12.35GB');
      });

      it('formats large numbers scaled', () => {
        expect(formatGigaBytes(1)).toEqual('1GB');
        expect(formatGigaBytes(1, 1)).toEqual('1.0GB');
        expect(formatGigaBytes(10)).toEqual('10GB');
        expect(formatGigaBytes(10 ** 2)).toEqual('100GB');
        expect(formatGigaBytes(10 ** 3)).toEqual('1TB');
        expect(formatGigaBytes(10 ** 4)).toEqual('10TB');
        expect(formatGigaBytes(10 ** 5)).toEqual('100TB');
        expect(formatGigaBytes(10 ** 6)).toEqual('1PB');
        expect(formatGigaBytes(10 ** 7)).toEqual('10PB');
        expect(formatGigaBytes(10 ** 8)).toEqual('100PB');
        expect(formatGigaBytes(10 ** 9)).toEqual('1EB');
      });

      it('formatting of too large numbers is not suported', () => {
        // formatting YB is out of range
        expect(() => scaledSIFormatter('B', 9)).toThrow();
      });
    });

    describe('scaled format with negative offset', () => {
      let formatMilligrams;

      beforeEach(() => {
        formatMilligrams = scaledSIFormatter('g', -1);
      });

      it('formats floating point numbers', () => {
        expect(formatMilligrams(1.0)).toEqual('1mg');
        expect(formatMilligrams(12.345)).toEqual('12.345mg');
        expect(formatMilligrams(12.345, 0)).toEqual('12mg');
        expect(formatMilligrams(12.345, 1)).toEqual('12.3mg');
        expect(formatMilligrams(12.345, 2)).toEqual('12.35mg');
      });

      it('formats large numbers scaled', () => {
        expect(formatMilligrams(10)).toEqual('10mg');
        expect(formatMilligrams(10 ** 2)).toEqual('100mg');
        expect(formatMilligrams(10 ** 3)).toEqual('1g');
        expect(formatMilligrams(10 ** 4)).toEqual('10g');
        expect(formatMilligrams(10 ** 5)).toEqual('100g');
        expect(formatMilligrams(10 ** 6)).toEqual('1kg');
        expect(formatMilligrams(10 ** 7)).toEqual('10kg');
        expect(formatMilligrams(10 ** 8)).toEqual('100kg');
      });

      it('formats negative numbers scaled', () => {
        expect(formatMilligrams(-12.345)).toEqual('-12.345mg');
        expect(formatMilligrams(-12.345, 0)).toEqual('-12mg');
        expect(formatMilligrams(-12.345, 1)).toEqual('-12.3mg');
        expect(formatMilligrams(-12.345, 2)).toEqual('-12.35mg');

        expect(formatMilligrams(-10)).toEqual('-10mg');
        expect(formatMilligrams(-100)).toEqual('-100mg');
        expect(formatMilligrams(-(10 ** 4))).toEqual('-10g');
      });
    });
  });

  describe('scaledBinaryFormatter', () => {
    describe('scaled format', () => {
      let formatScaledBin;

      beforeEach(() => {
        formatScaledBin = scaledBinaryFormatter('B');
      });

      it('formats bytes', () => {
        expect(formatScaledBin(12.345)).toEqual('12.345B');
        expect(formatScaledBin(12.345, 0)).toEqual('12B');
        expect(formatScaledBin(12.345, 1)).toEqual('12.3B');
        expect(formatScaledBin(12.345, 2)).toEqual('12.35B');
      });

      it('formats bytes in a binary scale', () => {
        expect(formatScaledBin(1)).toEqual('1B');
        expect(formatScaledBin(10)).toEqual('10B');
        expect(formatScaledBin(100)).toEqual('100B');
        expect(formatScaledBin(1000)).toEqual('1,000B');
        expect(formatScaledBin(10000)).toEqual('9.766KiB');

        expect(formatScaledBin(1 * 1024)).toEqual('1KiB');
        expect(formatScaledBin(10 * 1024)).toEqual('10KiB');
        expect(formatScaledBin(100 * 1024)).toEqual('100KiB');

        expect(formatScaledBin(1 * 1024 ** 2)).toEqual('1MiB');
        expect(formatScaledBin(10 * 1024 ** 2)).toEqual('10MiB');
        expect(formatScaledBin(100 * 1024 ** 2)).toEqual('100MiB');

        expect(formatScaledBin(1 * 1024 ** 3)).toEqual('1GiB');
        expect(formatScaledBin(10 * 1024 ** 3)).toEqual('10GiB');
        expect(formatScaledBin(100 * 1024 ** 3)).toEqual('100GiB');
      });
    });

    describe('scaled format with offset', () => {
      let formatGibibytes;

      beforeEach(() => {
        formatGibibytes = scaledBinaryFormatter('B', 3);
      });

      it('formats floating point numbers', () => {
        expect(formatGibibytes(12.888)).toEqual('12.888GiB');
        expect(formatGibibytes(12.888, 0)).toEqual('13GiB');
        expect(formatGibibytes(12.888, 1)).toEqual('12.9GiB');
        expect(formatGibibytes(12.888, 2)).toEqual('12.89GiB');
      });

      it('formats large numbers scaled', () => {
        expect(formatGibibytes(1)).toEqual('1GiB');
        expect(formatGibibytes(10)).toEqual('10GiB');
        expect(formatGibibytes(100)).toEqual('100GiB');
        expect(formatGibibytes(1000)).toEqual('1,000GiB');


        expect(formatGibibytes(1 * 1024)).toEqual('1TiB');
        expect(formatGibibytes(10 * 1024)).toEqual('10TiB');
        expect(formatGibibytes(100 * 1024)).toEqual('100TiB');

        expect(formatGibibytes(1 * 1024 ** 2)).toEqual('1PiB');
        expect(formatGibibytes(10 * 1024 ** 2)).toEqual('10PiB');
        expect(formatGibibytes(100 * 1024 ** 2)).toEqual('100PiB');

        expect(formatGibibytes(1 * 1024 ** 3)).toEqual('1EiB');
        expect(formatGibibytes(10 * 1024 ** 3)).toEqual('10EiB');
        expect(formatGibibytes(100 * 1024 ** 3)).toEqual('100EiB');
      });

      it('formatting of too large numbers is not suported', () => {
        // formatting YB is out of range
        expect(() => scaledBinaryFormatter('B', 9)).toThrow();
      });
    });
  });
});
