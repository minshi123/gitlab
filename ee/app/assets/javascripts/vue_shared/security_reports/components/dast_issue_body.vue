<script>
/**
 * Renders DAST body text
 * [severity]: [name]
 */

import ModalOpenName from '~/reports/components/modal_open_name.vue';
import SeverityBadge from './severity_badge.vue';

export default {
  name: 'DastIssueBody',
  components: {
    ModalOpenName,
    SeverityBadge,
  },
  props: {
    issue: {
      type: Object,
      required: true,
    },
    // failed || success
    status: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <div class="report-block-list-issue-description prepend-top-5 append-bottom-5">
    <div class="report-block-list-issue-description-text">
      <severity-badge :severity="issue.severity" />
      <modal-open-name :issue="issue" :status="status" class="js-modal-dast" />
    </div>
  </div>
</template>
