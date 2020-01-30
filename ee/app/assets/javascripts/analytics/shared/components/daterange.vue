<script>
import { GlDaterangePicker } from '@gitlab/ui';

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
      required: false,
      default: null,
    },
    containerClasses: {
      type: String,
      required: false,
      default:
        'daterange-container d-flex flex-column flex-lg-row align-items-lg-center justify-content-lg-end',
    },
    datepickerClasses: {
      type: String,
      required: false,
      default: 'd-flex flex-column flex-lg-row',
    },
    startPickerClasses: {
      type: String,
      required: false,
      default: 'd-flex flex-column flex-lg-row align-items-lg-center mr-lg-2 mb-2 mb-md-0',
    },
    endPickerClasses: {
      type: String,
      required: false,
      default: 'd-flex flex-column flex-lg-row align-items-lg-center',
    },
  },
  computed: {
    dateRange: {
      get() {
        return { startDate: this.startDate, endDate: this.endDate };
      },
      set({ startDate, endDate }) {
        this.$emit('change', { startDate, endDate });
      },
    },
  },
};
</script>
<template>
  <div v-if="show" :class="containerClasses">
    <gl-daterange-picker
      v-model="dateRange"
      :class="datepickerClasses"
      :default-start-date="startDate"
      :default-end-date="endDate"
      :default-min-date="minDate"
      theme="animate-picker"
      :start-picker-class="startPickerClasses"
      :end-picker-class="endPickerClasses"
    />
  </div>
</template>
