<script>
import { GlStackedColumnChart } from '@gitlab/ui/dist/charts';

export default {
  name: 'TasksByTypeChart',
  components: {
    GlStackedColumnChart,
  },
  props: {
    chartData: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hasData() {
      return Boolean(this.chartData?.data?.length);
    },
  },
};
</script>
<template>
  <div v-if="hasData">
    <gl-stacked-column-chart
      :data="chartData.data"
      :group-by="chartData.groupBy"
      x-axis-type="category"
      y-axis-type="value"
      :x-axis-title="__('Date')"
      :y-axis-title="s__('CycleAnalytics|Number of tasks')"
      :series-names="chartData.seriesNames"
    />
  </div>
  <div v-else class="bs-callout bs-callout-info">
    <p>{{ __('There is no data available. Please change your selection.') }}</p>
  </div>
</template>
