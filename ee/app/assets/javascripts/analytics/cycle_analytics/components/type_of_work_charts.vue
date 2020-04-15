<script>
import { GlLoadingIcon } from '@gitlab/ui';
import TasksByTypeChart from './tasks_by_type/tasks_by_type_chart.vue';

export default {
  name: 'TypeOfWorkCharts',
  components: { GlLoadingIcon, TasksByTypeChart },
  props: {
    isLoading: {
      type: Boolean,
      required: true,
    },
    tasksByTypeChartData: {
      type: Object,
      required: true,
    },
    selectedTasksByTypeFilters: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <div class="js-tasks-by-type-chart row">
    <div class="col-12">
      <h3>{{ s__('CycleAnalytics|Type of work') }}</h3>
      <tasks-by-type-chart
        v-if="isLoading"
        :chart-data="tasksByTypeChartData"
        :filters="selectedTasksByTypeFilters"
        @updateFilter="e => $emit('updateFilter', e)"
      />
      <gl-loading-icon v-else size="md" class="my-4 py-4" />
    </div>
  </div>
</template>
