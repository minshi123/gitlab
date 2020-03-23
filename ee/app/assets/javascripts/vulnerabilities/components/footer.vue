<script>
import IssueNote from 'ee/vue_shared/security_reports/components/issue_note.vue';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';

export default {
  name: 'VulnerabilityFooter',
  components: { IssueNote, SolutionCard },
  props: {
    feedback: {
      type: Object,
      required: false,
      default: null,
    },
    project: {
      type: Object,
      required: true,
    },
    solutionCard: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <div class="card my-4">
    <solution-card
      :solution="solutionCard.solution"
      :remediation="solutionCard.remediation"
      :has-mr="solutionCard.hasMr"
      :has-remediation="solutionCard.hasRemediation"
      :has-download="solutionCard.hasDownload"
      :vulnerability-feedback-help-path="solutionCard.vulnerabilityFeedbackHelpPath"
    />
    <template v-if="feedback" class="note">
      <div class="card-body">
        <issue-note :feedback="feedback" :project="project" />
      </div>
    </template>
  </div>
</template>
