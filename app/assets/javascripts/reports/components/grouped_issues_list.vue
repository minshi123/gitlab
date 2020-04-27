<script>
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';
import ReportItem from '~/reports/components/report_item.vue';

export default {
  components: {
    ReportItem,
    SmartVirtualList,
  },
  props: {
    groups: {
      type: Array,
      required: true,
    },
  },
  computed: {
    totalIssues() {
      return this.groups.reduce((total, { issues }) => {
        if (issues.length < 1) {
          return total;
        }
        // we need to add 1 because we rendering the heading as part of the list
        return total + issues.length + 1;
      }, 0);
    },
  },
};
</script>

<template>
  <smart-virtual-list :length="totalIssues" :remain="20" :size="32">
    <template v-for="group in groups">
      <h2 v-if="group.issues.length > 0" :key="group.name" :data-testid="group.name">
        {{ group.heading }}
      </h2>
      <report-item
        v-for="issue in group.issues"
        :key="issue.name"
        :issue="issue"
        :show-report-section-status-icon="false"
        status="none"
      />
    </template>
  </smart-virtual-list>
</template>
