import { __, n__, s__, sprintf } from '~/locale';

/**
 * Returns the index of an issue in given list
 * @param {Array} issues
 * @param {Object} issue
 */
export const findIssueIndex = (issues, issue) =>
  issues.findIndex(el => el.project_fingerprint === issue.project_fingerprint);

/**
 * Returns given vulnerability enriched with the corresponding
 * feedback (`dismissal` or `issue` type)
 * @param {Object} vulnerability
 * @param {Array} feedback
 */
export const enrichVulnerabilityWithFeedback = (vulnerability, feedback = []) =>
  feedback
    .filter(fb => fb.project_fingerprint === vulnerability.project_fingerprint)
    .reduce((vuln, fb) => {
      if (fb.feedback_type === 'dismissal') {
        return {
          ...vuln,
          isDismissed: true,
          dismissalFeedback: fb,
        };
      }
      if (fb.feedback_type === 'issue' && fb.issue_iid) {
        return {
          ...vuln,
          hasIssue: true,
          issue_feedback: fb,
        };
      }
      if (fb.feedback_type === 'merge_request' && fb.merge_request_iid) {
        return {
          ...vuln,
          hasMergeRequest: true,
          merge_request_feedback: fb,
        };
      }
      return vuln;
    }, vulnerability);

export const groupedTextBuilder = ({ reportType = '', critical = 0, high = 0, other = 0 }) => {
  let options = 0;
  const CRITICAL = 100;
  const HIGH = 10;
  const OTHER = 1;
  // TODO: Can we leverage args here?
  const sprintfVars = {
    reportType,
    critical,
    high,
    other,
  };

  if (critical) {
    options += 100;
  }
  if (high) {
    options += 10;
  }
  if (other) {
    options += 1;
  }

  switch (options) {
    case CRITICAL:
      return sprintf(
        n__(
          '%{reportType} detected %{critical} new critical vulnerability.',
          '%{reportType} detected %{critical} new critical vulnerabilities.',
          critical,
        ),
        sprintfVars,
      );

    case HIGH:
      return sprintf(
        n__(
          '%{reportType} detected %{high} new high vulnerability.',
          '%{reportType} detected %{high} new high vulnerabilities.',
          high,
        ),
        sprintfVars,
      );

    case OTHER:
      return sprintf(
        n__(
          '%{reportType} detected %{other} new vulnerability.',
          '%{reportType} detected %{other} new vulnerabilities.',
          other,
        ),
        sprintfVars,
      );

    case CRITICAL + HIGH:
      return sprintf(
        __('%{reportType} detected %{critical} new critical and %{high} new high vulnerabilities.'),
        sprintfVars,
      );

    case CRITICAL + OTHER:
      return sprintf(
        __('%{reportType} detected %{critical} critical and %{other} other new vulnerabilities.'),
        sprintfVars,
      );

    case HIGH + OTHER:
      return sprintf(
        __('%{reportType} detected %{high} high and %{other} other new vulnerabilities.'),
        sprintfVars,
      );

    case CRITICAL + HIGH + OTHER:
      return sprintf(
        __(
          '%{reportType} detected %{critical} critical, %{high} high, and %{other} other new vulnerabilities.',
        ),
        sprintfVars,
      );

    default:
      return sprintf(__('%{reportType} detected no new vulnerabilities.'), sprintfVars);
  }
};

export const statusIcon = (loading = false, failed = false, newIssues = 0, neutralIssues = 0) => {
  if (loading) {
    return 'loading';
  }

  if (failed || newIssues > 0 || neutralIssues > 0) {
    return 'warning';
  }

  return 'success';
};

/**
 * Counts issues. Simply returns the amount of existing and fixed Issues.
 * New Issues are divided into dismissed and added.
 *
 * @param newIssues
 * @param resolvedIssues
 * @param allIssues
 * @returns {{existing: number, added: number, dismissed: number, fixed: number}}
 */
export const countIssues = ({ newIssues = [], resolvedIssues = [], allIssues = [] } = {}) => {
  const dismissed = newIssues.reduce((sum, issue) => (issue.isDismissed ? sum + 1 : sum), 0);

  return {
    added: newIssues.length - dismissed,
    dismissed,
    existing: allIssues.length,
    fixed: resolvedIssues.length,
  };
};

/**
 * Generates a report message based on some of the report parameters and supplied messages.
 *
 * @param {Object} report The report to generate the text for
 * @param {String} reportType The report type. e.g. SAST
 * @param {String} errorMessage The message to show if there's an error in the report
 * @param {String} loadingMessage The message to show if the report is still loading
 * @returns {String}
 */
export const groupedReportText = (report, reportType, errorMessage, loadingMessage) => {
  const { paths } = report;

  if (report.hasError) {
    return errorMessage;
  }

  if (report.isLoading) {
    return loadingMessage;
  }

  return groupedTextBuilder({
    // TODO: Update the issue counting to pass the severities
    ...countIssues(report),
    reportType,
    paths,
  });
};

/**
 * Generates the added, fixed, and existing vulnerabilities from the API report.
 *
 * @param {Object} diff The original reports.
 * @param {Object} enrichData Feedback data to add to the reports.
 * @returns {Object}
 */
export const parseDiff = (diff, enrichData) => {
  const enrichVulnerability = vulnerability => ({
    ...enrichVulnerabilityWithFeedback(vulnerability, enrichData),
    category: vulnerability.report_type,
    title: vulnerability.message || vulnerability.name,
  });

  return {
    added: diff.added ? diff.added.map(enrichVulnerability) : [],
    fixed: diff.fixed ? diff.fixed.map(enrichVulnerability) : [],
    existing: diff.existing ? diff.existing.map(enrichVulnerability) : [],
  };
};
