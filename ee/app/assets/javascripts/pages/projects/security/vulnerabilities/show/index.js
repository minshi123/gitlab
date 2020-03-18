import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import HeaderApp from 'ee/vulnerabilities/components/app.vue';

function createSolutionCardApp() {
  const el = document.getElementById('js-vulnerability-solution');

  if (!el) {
    return false;
  }

  const { solution, vulnerabilityFeedbackHelpPath, vulnerabilityState } = el.dataset;
  const hasMr = parseBoolean(el.dataset.hasMr);
  const remediation = JSON.parse(el.dataset.remediation);
  const hasDownload = Boolean(
    vulnerabilityState !== 'resolved' && remediation?.diff?.length && !hasMr,
  );

  const props = {
    solution,
    remediation,
    hasDownload,
    hasMr,
    hasRemediation: Boolean(remediation),
    vulnerabilityFeedbackHelpPath,
    isStandaloneVulnerability: true,
  };

  return new Vue({
    el,
    render: h =>
      h(SolutionCard, {
        props,
      }),
  });
}

function createHeaderApp() {
  const el = document.getElementById('js-vulnerability-management-app');
  const vulnerability = JSON.parse(el.dataset.vulnerabilityJson);
  const pipeline = JSON.parse(el.dataset.pipelineJson);

  // Get description and name from occurrence onto vulnerability
  const occurrence = JSON.parse(el.dataset.occurrenceJson);
  occurrence.raw_metadata = JSON.parse(occurrence.raw_metadata);
  vulnerability.description = occurrence.raw_metadata.description;
  vulnerability.name = occurrence.name;

  const { projectFingerprint, createIssueUrl } = el.dataset;

  return new Vue({
    el,

    render: h =>
      h(HeaderApp, {
        props: {
          vulnerability,
          pipeline,
          projectFingerprint,
          createIssueUrl,
        },
      }),
  });
}

window.addEventListener('DOMContentLoaded', () => {
  createHeaderApp();
  createSolutionCardApp();
});
