<script>
import IssueNote from 'ee/vue_shared/security_reports/components/issue_note.vue';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import StateHistory from './state_history.vue';

export default {
  name: 'VulnerabilityFooter',
  components: { IssueNote, SolutionCard, StateHistory },
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
    solutionInfo: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hasSolution() {
      return this.solutionInfo.solution || this.solutionInfo.hasRemediation;
    },
  },
};
</script>
<template>
  <div>
    <solution-card v-if="hasSolution" v-bind="solutionInfo" />
    <div v-if="feedback" class="card">
      <issue-note :feedback="feedback" :project="project" class="card-body" />
    </div>
    <hr />
    <state-history />
  </div>
</template>
