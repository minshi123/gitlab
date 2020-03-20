<script>
import { mapActions, mapState } from 'vuex';
import { GlFilteredSearch } from '@gitlab/ui';
import { s__ } from '~/locale';
import DateTimePicker from '~/vue_shared/components/date_time_picker/date_time_picker.vue';
import { timeRanges } from '~/vue_shared/constants';
import PodSearchToken from './pod_search_token.vue';

export default {
  components: {
    GlFilteredSearch,
    DateTimePicker,
  },
  props: {
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      timeRanges,
      searchQuery: [], // TODO Connect this to the store?
    };
  },
  computed: {
    ...mapState('environmentLogs', ['timeRange', 'pods']),

    timeRangeModel: {
      get() {
        return this.timeRange.selected;
      },
      set(val) {
        this.setTimeRange(val);
      },
    },

    tokens() {
      const options = this.pods.options.map(podName => {
        return { value: podName, title: podName };
      });

      return [
        {
          icon: 'pod',
          type: 'pod',
          title: s__('Environments|Pod'),
          token: PodSearchToken,
          options,
          unique: true,
        },
      ];
    },
  },
  methods: {
    ...mapActions('environmentLogs', ['showFilteredLogs', 'setTimeRange']),

    applyFilters(filters) {
      this.showFilteredLogs(filters);
    },
  },
};
</script>
<template>
  <div>
    <gl-filtered-search
      v-model="searchQuery"
      class="mb-2 gl-h-32 pr-2"
      :disabled="disabled"
      :available-tokens="tokens"
      @submit="applyFilters"
    />

    <date-time-picker
      ref="dateTimePicker"
      v-model="timeRangeModel"
      :disabled="disabled"
      :options="timeRanges"
      class="mb-2 gl-h-32 pr-2 d-block date-time-picker-wrapper"
      right
    />
  </div>
</template>
