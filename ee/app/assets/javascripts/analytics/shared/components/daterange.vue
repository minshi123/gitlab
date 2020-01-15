<script>
import { GlDaterangePicker } from '@gitlab/ui';
import dateFormat from 'dateformat';
import { getDayDifference } from '~/lib/utils/datetime_utility';
import createFlash, { hideFlash } from '~/flash';
import { __, sprintf } from '~/locale';
import { DATE_RANGE_LIMIT, dateFormats } from '../constants';

const removeNotice = () => {
  const flashEl = document.querySelector('.flash-notice');
  if (flashEl) {
    hideFlash(flashEl);
  }
};

export default {
  components: {
    GlDaterangePicker,
  },
  props: {
    show: {
      type: Boolean,
      required: false,
      default: true,
    },
    startDate: {
      type: Date,
      required: false,
      default: null,
    },
    endDate: {
      type: Date,
      required: false,
      default: null,
    },
    minDate: {
      type: Date,
      rerquired: false,
      default: null,
    },
  },
  computed: {
    dateRange: {
      get() {
        return { startDate: this.startDate, endDate: this.endDate };
      },
      set({ startDate, endDate }) {
        removeNotice();
        const numberOfDays = getDayDifference(startDate, endDate);

        if (numberOfDays < DATE_RANGE_LIMIT) this.$emit('change', { startDate, endDate });
        else {
          createFlash(
            sprintf(
              __(
                'Date range has not been applied as it exceeds %{dateRangeLimit} days. Showing data from %{startDate} until %{endDate}',
              ),
              {
                dateRangeLimit: DATE_RANGE_LIMIT,
                startDate: dateFormat(this.startDate, dateFormats.defaultDate),
                endDate: dateFormat(this.endDate, dateFormats.defaultDate),
              },
            ),
            'notice',
          );
        }
      },
    },
  },
};
</script>
<template>
  <div
    v-if="show"
    class="daterange-container d-flex flex-column flex-lg-row align-items-lg-center justify-content-lg-end"
  >
    <gl-daterange-picker
      v-model="dateRange"
      class="d-flex flex-column flex-lg-row"
      :default-start-date="startDate"
      :default-end-date="endDate"
      :default-min-date="minDate"
      theme="animate-picker"
      start-picker-class="d-flex flex-column flex-lg-row align-items-lg-center mr-lg-2 mb-2 mb-md-0"
      end-picker-class="d-flex flex-column flex-lg-row align-items-lg-center"
    />
  </div>
</template>
