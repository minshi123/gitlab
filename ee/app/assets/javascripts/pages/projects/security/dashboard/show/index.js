import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import Vue from 'vue';

window.addEventListener('DOMContentLoaded', () => {
  const el = document.getElementById('vulnerability-solution');
  const { solution, remediations, vulnerabilityFeedbackHelpPath, vulnerabilityState } = el.dataset;
  const [remediation] = JSON.parse(remediations);
  const mergeRequestFeedback = JSON.parse(el.dataset.mergeRequestFeedback);
  const hasMr = Boolean(mergeRequestFeedback?.merge_request_iid);

  const remediationDiff = remediation && remediation.diff;
  const hasDownload = Boolean(
    vulnerabilityState !== 'resolved' &&
      remediationDiff &&
      remediationDiff.length > 0 &&
      (!hasMr && remediation),
  );

  const props = {
    solution,
    remediation,
    hasDownload,
    hasMr,
    hasRemediation: Boolean(remediation),
    vulnerabilityFeedbackHelpPath,
  };

  return new Vue({
    el,
    render: h =>
      h(SolutionCard, {
        props,
      }),
  });
});
