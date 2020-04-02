import { getNewPaginationPage } from 'ee/packages/list/utils';

describe('Packages list utils', () => {
  describe('packageTypeDisplay', () => {
    it('returns the current page when total items exceeds pagniation', () => {
      expect(getNewPaginationPage(2, 20, 21)).toBe(2);
    });

    it('returns the previous page when total items is lower than or equal to pagination', () => {
      expect(getNewPaginationPage(2, 20, 20)).toBe(1);
    });

    it('returns the first page when totalItems is lower than or equal to perPage', () => {
      expect(getNewPaginationPage(4, 20, 20)).toBe(1);
    });

    describe('works when a different perPage is used', () => {
      it('returns the current page', () => {
        expect(getNewPaginationPage(2, 10, 11)).toBe(2);
      });

      it('returns the previous page', () => {
        expect(getNewPaginationPage(2, 10, 10)).toBe(1);
      });
    });

    describe.each`
      currentPage | perPage | totalItems | expectedResult
      ${1}        | ${20}   | ${20}      | ${1}
      ${2}        | ${20}   | ${20}      | ${1}
      ${3}        | ${20}   | ${40}      | ${2}
      ${4}        | ${20}   | ${60}      | ${3}
    `(`works across numerious pages`, ({ currentPage, perPage, totalItems, expectedResult }) => {
      it(`when currentPage is ${currentPage} return to the previous page ${expectedResult}`, () => {
        expect(getNewPaginationPage(currentPage, perPage, totalItems)).toBe(expectedResult);
      });
    });
  });
});
