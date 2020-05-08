<script>
import MetricCard from '../../shared/components/metric_card.vue';

const emptyState = [{ label: 'Lead time', value: null }, { label: 'Cycle time', value: null }];

const placeholder = [
  { label: 'Lead time', value: '2', unit: 'days' },
  { label: 'Cycle time', value: '1.5', unit: 'days' },
];

export default {
  name: 'TimeMetricsCard',
  components: {
    MetricCard,
  },
  props: {
    groupPath: {
      type: String,
      required: true,
    },
    additionalParams: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      data: [],
      loading: false,
    };
  },
  watch: {
    additionalParams() {
      this.fetchData();
    },
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.data = placeholder;
    },
  },
};
</script>
<template>
  <metric-card :title="__('Time')" :metrics="data" :is-loading="loading" />
</template>
