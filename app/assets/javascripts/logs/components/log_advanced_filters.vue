<script>
import { mapActions, mapState } from 'vuex';
import { GlFilteredSearch, GlFilteredSearchToken } from '@gitlab/ui';
import { s__ } from '~/locale';
import DateTimePicker from '~/vue_shared/components/date_time_picker/date_time_picker.vue';
import { timeRanges } from '~/vue_shared/constants';
import { TOKEN_TYPE_POD_NAME } from '../constants';

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
    };
  },
  computed: {
    ...mapState('environmentLogs', ['timeRange', 'pods', 'logs']),

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
          type: TOKEN_TYPE_POD_NAME,
          title: s__('Environments|Pod name'),
          token: {
            components: {
              GlFilteredSearchToken,
            },
            // A token with a single `=` operator
            template: `<gl-filtered-search-token
              :operators="[{ value: '=', description: 'is', default: 'true' }]"
              v-bind="{ ...$props, ...$attrs }"
              v-on="$listeners"
            />`,
          },
          options,
          unique: true,
        },
      ];
    },
  },
  methods: {
    ...mapActions('environmentLogs', ['showFilteredLogs', 'setTimeRange']),

    filteredSearchSubmit(filters) {
      this.showFilteredLogs(filters);
    },
  },
};
</script>
<template>
  <div>
    <div class="mb-2 pr-2 flex-grow-1 min-width-0">
      <gl-filtered-search
        ref="filteredSearch"
        class="gl-h-32"
        :disabled="disabled || logs.isLoading"
        :available-tokens="tokens"
        @submit="filteredSearchSubmit"
      />
    </div>

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
