<script>
import Api from 'ee/api';
import { __ } from '~/locale';
import createFlash from '~/flash';
import { slugify } from '~/lib/utils/text_utility';
import MetricCard from '../../shared/components/metric_card.vue';
import { removeFlash } from '../utils';

export default {
  name: 'RecentActivityCard',
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
      default: () => ({}),
    },
  },
  data() {
    return {
      data: [],
      loading: false,
    };
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      removeFlash();
      this.loading = true;
      return Api.cycleAnalyticsSummaryData({
        group_id: this.groupPath,
        ...this.additionalParams,
      })
        .then(({ data }) => {
          this.data = data.map(({ title: label, value }) => ({
            value: value || '-',
            label,
            key: slugify(label),
          }));
        })
        .catch(() => {
          createFlash(__('There was an error while fetching value stream analytics summary data.'));
        })
        .finally(() => {
          this.loading = false;
        });
    },
  },
};
</script>
<template>
  <div class="wrapper mt-3">
    <metric-card :title="__('Recent Activity')" :metrics="data" :is-loading="loading" />
  </div>
</template>
