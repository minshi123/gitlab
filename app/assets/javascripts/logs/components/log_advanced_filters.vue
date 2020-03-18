<script>
import { s__ } from '~/locale';
import DateTimePicker from '~/vue_shared/components/date_time_picker/date_time_picker.vue';
import { mapActions, mapState } from 'vuex';
import {
  GlIcon,
  GlDropdown,
  GlDropdownHeader,
  GlDropdownDivider,
  GlDropdownItem,
  GlSearchBoxByClick,
} from '@gitlab/ui';
import { timeRanges } from '~/vue_shared/constants';

export default {
  components: {
    GlIcon,
    GlDropdown,
    GlDropdownHeader,
    GlDropdownDivider,
    GlDropdownItem,
    GlSearchBoxByClick,
    DateTimePicker,
  },
  props: {
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  data() {
    return {
      timeRanges,
      searchQuery: '',
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

    podDropdownText() {
      if (this.pods.current) {
        return this.pods.current;
      }
      return s__('Environments|All pods');
    },
  },
  methods: {
    ...mapActions('environmentLogs', ['setSearch', 'showPodLogs', 'setTimeRange']),
  },
};
</script>
<template>
  <div class="d-flex">
    <gl-dropdown
      id="pods-dropdown"
      :text="podDropdownText"
      :disabled="disabled"
      class="pr-2 gl-h-32 js-pods-dropdown"
      toggle-class="dropdown-menu-toggle"
    >
      <gl-dropdown-header class="text-center">
        {{ s__('Environments|Fiter by pod') }}
      </gl-dropdown-header>

      <gl-dropdown-item v-if="!pods.options.length" :disabled="true">
        <span class="text-muted">
          {{ s__('Environments|No pods to display') }}
        </span>
      </gl-dropdown-item>

      <template v-else>
        <gl-dropdown-item key="all-pods" @click="showPodLogs(null)">
          <div class="d-flex">
            <gl-icon
              :class="{ invisible: pods.current !== null }"
              name="status_success_borderless"
            />
            <div class="flex-grow-1">{{ s__('Environments|All pods') }}</div>
          </div>
        </gl-dropdown-item>
        <gl-dropdown-divider />
        <gl-dropdown-item
          v-for="podName in pods.options"
          :key="podName"
          class="text-nowrap"
          @click="showPodLogs(podName)"
        >
          <div class="d-flex">
            <gl-icon
              :class="{ invisible: podName !== pods.current }"
              name="status_success_borderless"
            />
            <div class="flex-grow-1">{{ podName }}</div>
          </div>
        </gl-dropdown-item>
      </template>
    </gl-dropdown>

    <gl-search-box-by-click
      v-model.trim="searchQuery"
      :disabled="disabled"
      :placeholder="s__('Environments|Search')"
      class="pr-2 js-logs-search"
      type="search"
      autofocus
      @submit="setSearch(searchQuery)"
    />

    <!-- TODO Update style using component and check on tooltip to truncate again -->
    <date-time-picker
      ref="dateTimePicker"
      v-model="timeRangeModel"
      class=" pr-2 gl-h-32"
      style="display: block; width: 160px;"
      right
      :disabled="disabled"
      :options="timeRanges"
    />
  </div>
</template>
