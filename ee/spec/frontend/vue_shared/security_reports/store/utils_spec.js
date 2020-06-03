import {
  findIssueIndex,
  groupedTextBuilder,
  statusIcon,
  countIssues,
  groupedReportText,
} from 'ee/vue_shared/security_reports/store/utils';
import filterByKey from 'ee/vue_shared/security_reports/store/utils/filter_by_key';
import getFileLocation from 'ee/vue_shared/security_reports/store/utils/get_file_location';

describe('security reports utils', () => {
  describe('findIssueIndex', () => {
    let issuesList;

    beforeEach(() => {
      issuesList = [
        { project_fingerprint: 'abc123' },
        { project_fingerprint: 'abc456' },
        { project_fingerprint: 'abc789' },
      ];
    });

    it('returns index of found issue', () => {
      const issue = {
        project_fingerprint: 'abc456',
      };

      expect(findIssueIndex(issuesList, issue)).toEqual(1);
    });

    it('returns -1 when issue is not found', () => {
      const issue = {
        project_fingerprint: 'foo',
      };

      expect(findIssueIndex(issuesList, issue)).toEqual(-1);
    });
  });

  describe('filterByKey', () => {
    it('filters the array with the provided key', () => {
      const array1 = [{ id: '1234' }, { id: 'abg543' }, { id: '214swfA' }];
      const array2 = [{ id: '1234' }, { id: 'abg543' }, { id: '453OJKs' }];

      expect(filterByKey(array1, array2, 'id')).toEqual([{ id: '214swfA' }]);
    });
  });

  describe('getFileLocation', () => {
    const hostname = 'https://hostna.me';
    const path = '/deeply/nested/route';

    it('should return the correct location when passed both a hostname and a path', () => {
      const result = getFileLocation({ hostname, path });

      expect(result).toEqual(`${hostname}${path}`);
    });

    it('should return null if the hostname is not present', () => {
      const result = getFileLocation({ path });

      expect(result).toBeNull();
    });

    it('should return null if the path is not present', () => {
      const result = getFileLocation({ hostname });

      expect(result).toBeNull();
    });

    it('should return null if the argument is undefined', () => {
      const result = getFileLocation(undefined);

      expect(result).toBeNull();
    });
  });

  describe('groupedTextBuilder', () => {
    const critical = 2;
    const high = 4;
    const other = 7;

    it.each`
      vulnerabilities              | message
      ${{}}                        | ${' detected no new vulnerabilities.'}
      ${{ critical }}              | ${' detected 2 new critical vulnerabilities.'}
      ${{ high }}                  | ${' detected 4 new high vulnerabilities.'}
      ${{ other }}                 | ${' detected 7 new vulnerabilities.'}
      ${{ critical, high }}        | ${' detected 2 new critical and 4 new high vulnerabilities.'}
      ${{ critical, other }}       | ${' detected 2 critical and 7 other new vulnerabilities.'}
      ${{ high, other }}           | ${' detected 4 high and 7 other new vulnerabilities.'}
      ${{ critical, high, other }} | ${' detected 2 critical, 4 high, and 7 other new vulnerabilities.'}
    `('should build the message as "$message"', ({ vulnerabilities, message }) => {
      expect(groupedTextBuilder(vulnerabilities)).toEqual(message);
    });

    it.each`
      vulnerabilities                 | message
      ${{ critical: 1 }}              | ${' detected 1 new critical vulnerability.'}
      ${{ high: 1 }}                  | ${' detected 1 new high vulnerability.'}
      ${{ other: 1 }}                 | ${' detected 1 new vulnerability.'}
      ${{ critical, high, other: 1 }} | ${' detected 2 critical, 4 high, and 1 other new vulnerabilities.'}
    `('should handle single vulnerabilities for "$message"', ({ vulnerabilities, message }) => {
      expect(groupedTextBuilder(vulnerabilities)).toEqual(message);
    });

    it('should pass through the report type', () => {
      const reportType = 'HAL';
      expect(groupedTextBuilder({ reportType })).toEqual('HAL detected no new vulnerabilities.');
    });
  });

  describe('statusIcon', () => {
    describe('with failed report', () => {
      it('returns warning', () => {
        expect(statusIcon(false, true)).toEqual('warning');
      });
    });

    describe('with new issues', () => {
      it('returns warning', () => {
        expect(statusIcon(false, false, 1)).toEqual('warning');
      });
    });

    describe('with neutral issues', () => {
      it('returns warning', () => {
        expect(statusIcon(false, false, 0, 1)).toEqual('warning');
      });
    });

    describe('without new or neutal issues', () => {
      it('returns success', () => {
        expect(statusIcon()).toEqual('success');
      });
    });
  });

  describe('countIssues', () => {
    const allIssues = [{}];
    const resolvedIssues = [{}];
    const dismissedIssues = [{ isDismissed: true }];
    const addedIssues = [{ isDismissed: false }];

    it('returns 0 for all counts if everything is empty', () => {
      expect(countIssues()).toEqual({
        added: 0,
        dismissed: 0,
        existing: 0,
        fixed: 0,
      });
    });

    it('counts `allIssues` as existing', () => {
      expect(countIssues({ allIssues })).toEqual({
        added: 0,
        dismissed: 0,
        existing: 1,
        fixed: 0,
      });
    });

    it('counts `resolvedIssues` as fixed', () => {
      expect(countIssues({ resolvedIssues })).toEqual({
        added: 0,
        dismissed: 0,
        existing: 0,
        fixed: 1,
      });
    });

    it('counts `newIssues` which are dismissed as dismissed', () => {
      expect(countIssues({ newIssues: dismissedIssues })).toEqual({
        added: 0,
        dismissed: 1,
        existing: 0,
        fixed: 0,
      });
    });

    it('counts `newIssues` which are not dismissed as added', () => {
      expect(countIssues({ newIssues: addedIssues })).toEqual({
        added: 1,
        dismissed: 0,
        existing: 0,
        fixed: 0,
      });
    });

    it('counts everything', () => {
      expect(
        countIssues({ newIssues: [...addedIssues, ...dismissedIssues], resolvedIssues, allIssues }),
      ).toEqual({
        added: 1,
        dismissed: 1,
        existing: 1,
        fixed: 1,
      });
    });
  });

  describe('groupedReportText', () => {
    const reportType = 'dummyReport';
    const errorMessage = 'Something went wrong';
    const loadingMessage = 'The report is still loading';
    const baseReport = { paths: [] };

    it("should return the error message when there's an error", () => {
      const report = { ...baseReport, hasError: true };
      const result = groupedReportText(report, reportType, errorMessage, loadingMessage);

      expect(result).toBe(errorMessage);
    });

    it("should return the loading message when it's loading", () => {
      const report = { ...baseReport, isLoading: true };
      const result = groupedReportText(report, reportType, errorMessage, loadingMessage);

      expect(result).toBe(loadingMessage);
    });

    it("should call groupedTextBuilder if it isn't loading and doesn't have an error", () => {
      const report = { ...baseReport };
      const result = groupedReportText(report, reportType, errorMessage, loadingMessage);

      expect(result).toBe(`${reportType} detected no new vulnerabilities.`);
    });
  });
});
