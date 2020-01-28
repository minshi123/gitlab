import { groupByDayRanges } from 'ee/security_dashboard/store/modules/project_scanning/utils';

describe('Project scanning store utils', () => {
  describe('groupByDayRanges', () => {
    it('is a function', () => {
      expect(typeof groupByDayRanges).toBe('function');
    });
  });
});
