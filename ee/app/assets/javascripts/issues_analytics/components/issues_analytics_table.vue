<script>
import { GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'IssuesAnalyticsTable',
  components: {
    GlTable,
  },
  props: {
    issues: {
      type: Array,
      required: true,
    },
  },
  tableHeaderFields: [
    {
      key: 'issue_details',
      label: s__('IssueAnalytics|Issue'),
      thClass: 'w-30p',
      tdClass: 'table-col d-flex align-items-center',
    },
    {
      key: 'age',
      label: s__('IssueAnalytics|Age'),
      class: 'text-right',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'status',
      label: s__('IssueAnalytics|Status'),
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'milestone',
      label: s__('IssueAnalytics|Milestone'),
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'weight',
      label: s__('IssueAnalytics|Weight'),
      class: 'text-right',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'due_date',
      label: s__('IssueAnalytics|Due date'),
      class: 'text-right',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'assignees',
      label: s__('IssueAnalytics|Assignees'),
      class: 'text-right',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
    {
      key: 'opened_by',
      label: s__('IssueAnalytics|Opened by'),
      class: 'text-right',
      tdClass: 'table-col d-flex align-items-center d-sm-table-cell',
    },
  ],
};
</script>
<template>
  <gl-table
    class="mt-8"
    :fields="$options.tableHeaderFields"
    :items="issues"
    stacked="sm"
    thead-class="thead-white border-bottom"
    striped
  >
    <template #cell(issue_details)="items">
      <div class="d-flex flex-column flex-grow align-items-end align-items-sm-start">
        <div class="str-truncated my-2">
          <gl-link :href="items.item.web_url" target="_blank" class="font-weight-bold text-plain">{{
            items.item.title
          }}</gl-link>
        </div>
        <ul class="horizontal-list list-items-separated text-secondary mb-0">
          <li>!{{ items.item.iid }}</li>
          <li>{{ getTimeAgoString(items.item.created_at) }}</li>
          <li v-if="items.item.milestone">
            <span class="d-flex align-items-center">
              <gl-icon name="clock" class="mr-2" />
              {{ items.item.milestone.title }}
            </span>
          </li>
        </ul>
      </div>
    </template>

    <template #cell(age)="{ value }">
      {{ value }}
    </template>

    <template #cell(status)="{ value }">
      {{ value }}
    </template>

    <template #cell(milestone)="{ value }">
      {{ value }}
    </template>

    <template #cell(weight)="{ value }">
      {{ value }}
    </template>

    <template #cell(assignees)="{ value }">
      {{ value }}
    </template>

    <template #cell(owned_by)="{ value }">
      {{ value }}
    </template>
  </gl-table>
</template>
