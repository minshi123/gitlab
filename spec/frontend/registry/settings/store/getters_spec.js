import * as getters from '~/registry/settings/store/getters';
import * as utils from '~/registry/shared/utils';
import { formOptions } from '../../shared/mock_data';

describe('Getters registry settings store', () => {
  const settings = {
    cadence: 'foo',
    keep_n: 'bar',
    older_than: 'baz',
  };

  describe.each`
    getter            | variable        | formOption
    ${'getCadence'}   | ${'cadence'}    | ${'cadence'}
    ${'getKeepN'}     | ${'keep_n'}     | ${'keepN'}
    ${'getOlderThan'} | ${'older_than'} | ${'olderThan'}
  `('Options getter', ({ getter, variable, formOption }) => {
    beforeEach(() => {
      utils.findDefaultOption = jest.fn();
    });

    it(`${getter} returns ${variable} when ${variable} exists in settings`, () => {
      expect(getters[getter]({ settings })).toBe(settings[variable]);
    });

    it(`${getter} calls findDefaultOption when ${variable} does not exists in settings`, () => {
      getters[getter]({ settings: {}, formOptions });
      expect(utils.findDefaultOption).toHaveBeenCalledWith(formOptions[formOption]);
    });
  });

  describe('getIsEdited', () => {
    it('returns false when original is equal to settings', () => {
      const same = { foo: 'bar' };
      expect(getters.getIsEdited({ original: same, settings: same })).toBe(false);
    });

    it('returns true when original is different from settings', () => {
      expect(getters.getIsEdited({ original: { foo: 'bar' }, settings: { foo: 'baz' } })).toBe(
        true,
      );
    });
  });

  describe('getIsDisabled', () => {
    it('returns true when original is empty or null and enableHistoricEntries is false', () => {
      expect(getters.getIsDisabled({ original: undefined, enableHistoricEntries: false })).toBe(
        true,
      );
    });

    it('returns false when original is not empty', () => {
      expect(getters.getIsDisabled({ original: { foo: 'bar' } })).toBe(false);
    });
    it('returns false when original is empty and enableHistoricEntries is true', () => {
      expect(
        getters.getIsDisabled({ original: { foo: 'bar', enableHistoricEntries: false } }),
      ).toBe(false);
    });
  });
});
