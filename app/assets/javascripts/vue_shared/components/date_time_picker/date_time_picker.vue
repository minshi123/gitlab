<script>
import { GlButton, GlDropdown, GlDropdownItem, GlFormGroup } from '@gitlab/ui';
import { __, sprintf } from '~/locale';

import { convertToFixedRange, isEqualTimeRanges, findTimeRange } from '~/lib/utils/datetime_range';

import Icon from '~/vue_shared/components/icon.vue';
import DateTimePickerInput from './date_time_picker_input.vue';
import {
  defaultTimeRanges,
  isValidDate,
  stringToISODate,
  ISODateToString,
  truncateZerosInDateTime,
  isDateTimePickerInputValid,
} from './date_time_picker_lib';

const events = {
  input: 'input',
  invalid: 'invalid',
};

export default {
  components: {
    Icon,
    DateTimePickerInput,
    GlFormGroup,
    GlButton,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    value: {
      type: Object,
      required: false,
      default: () => defaultTimeRanges.find(tr => tr.default),
    },
    options: {
      type: Array,
      required: false,
      default: () => defaultTimeRanges,
    },
  },
  data() {
    const { startTime, endTime } = convertToFixedRange(this.value);
    return {
      timeRange: this.value,
      startDate: startTime,
      endDate: endTime,
    };
  },
  computed: {
    startInputValid() {
      return isValidDate(this.startDate);
    },
    endInputValid() {
      return isValidDate(this.endDate);
    },
    isValid() {
      return this.startInputValid && this.endInputValid;
    },

    startInput: {
      get() {
        return this.startInputValid ? this.formatDate(this.startDate) : this.startDate;
      },
      set(val) {
        // Attempt to set a formatted date if possible
        this.startDate = isDateTimePickerInputValid(val) ? stringToISODate(val) : val;
        this.value = null;
      },
    },
    endInput: {
      get() {
        return this.endInputValid ? this.formatDate(this.endDate) : this.endDate;
      },
      set(val) {
        // Attempt to set a formatted date if possible
        this.endDate = isDateTimePickerInputValid(val) ? stringToISODate(val) : val;
        this.value = null;
      },
    },

    timeWindowText() {
      const fullTimeRange = findTimeRange(this.value, this.options);
      if (fullTimeRange) {
        return fullTimeRange.label;
      }

      const { startTime, endTime } = this.value;
      if (isValidDate(startTime) && isValidDate(endTime)) {
        return sprintf(__('%{start} to %{end}'), {
          start: this.formatDate(startTime),
          end: this.formatDate(endTime),
        });
      }

      return '';
    },
  },
  mounted() {
    // Validate on mounted, and trigger an update if needed
    if (!this.isValid) {
      this.$emit(events.invalid);
    }
  },
  methods: {
    formatDate(date) {
      return truncateZerosInDateTime(ISODateToString(date));
    },
    closeDropdown() {
      this.$refs.dropdown.hide();
    },

    isTimeRangeActive(option) {
      return isEqualTimeRanges(option, this.value);
    },

    setQuickRange(option) {
      this.value = option;

      this.$emit(events.input, this.value);
    },
    setFixedRange() {
      this.value = convertToFixedRange({
        startTime: this.startDate,
        endTime: this.endDate,
      });

      this.$emit(events.input, this.value);
    },
  },
};
</script>
<template>
  <gl-dropdown :text="timeWindowText" class="date-time-picker" menu-class="date-time-picker-menu">
    <div class="d-flex justify-content-between gl-p-2">
      <gl-form-group
        :label="__('Custom range')"
        label-for="custom-from-time"
        label-class="gl-pb-1"
        class="custom-time-range-form-group col-md-7 gl-pl-1 gl-pr-0 m-0"
      >
        <div class="gl-pt-2">
          <date-time-picker-input
            id="custom-time-from"
            v-model="startInput"
            :label="__('From')"
            :state="startInputValid"
          />
          <date-time-picker-input
            id="custom-time-to"
            v-model="endInput"
            :label="__('To')"
            :state="endInputValid"
          />
        </div>
        <gl-form-group>
          <gl-button @click="closeDropdown">{{ __('Cancel') }}</gl-button>
          <gl-button variant="success" :disabled="!isValid" @click="setFixedRange()">
            {{ __('Apply') }}
          </gl-button>
        </gl-form-group>
      </gl-form-group>
      <gl-form-group label-for="group-id-dropdown" class="col-md-5 gl-pl-1 gl-pr-1 m-0">
        <template #label>
          <span class="gl-pl-5">{{ __('Quick range') }}</span>
        </template>

        <gl-dropdown-item
          v-for="(option, index) in options"
          :key="index"
          :active="isOptionActive(option)"
          active-class="active"
          @click="setQuickRange(option)"
        >
          <icon
            name="mobile-issue-close"
            class="align-bottom"
            :class="{ invisible: !isTimeRangeActive(timeRangeOption) }"
          />
          {{ timeRangeOption.label }}
        </gl-dropdown-item>
      </gl-form-group>
    </div>
  </gl-dropdown>
</template>
