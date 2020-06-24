<script>
import { __ } from '~/locale';
import { mapActions } from 'vuex';
import {
  GlIcon,
  GlButtonGroup,
  GlDeprecatedButton,
  GlButton,
  GlNewDropdown,
  GlNewDropdownItem,
  GlNewDropdownDivider,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlTooltipDirective,
} from '@gitlab/ui';

export default {
  components: {
    GlIcon,
    GlButtonGroup,
    GlDeprecatedButton,
    GlButton,

    // GlDropdown,
    // GlDropdownItem,
    // GlDropdownDivider,
    GlNewDropdown,
    GlNewDropdownItem,
    GlNewDropdownDivider,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  data() {
    return {
      refreshInterval: null,
      timeoutId: null,
    };
  },
  watch: {
    refreshInterval() {
      if (this.refreshInterval !== null) {
        this.startAutoRefresh();
      } else {
        this.stopAutoRefresh();
      }
    },
  },
  computed: {
    dropdownText() {
      if (this.refreshInterval) {
        return this.refreshInterval.shortLabel;
      }
      return '';
    },
  },
  methods: {
    ...mapActions('monitoringDashboard', ['fetchDashboardData']),

    refresh() {
      this.fetchDashboardData();
    },
    startAutoRefresh() {
      const schedule = () => {
        if (this.refreshInterval) {
          this.timeoutId = setTimeout(this.startAutoRefresh, this.refreshInterval.interval);
        }
      };

      this.stopAutoRefresh();
      if (!document.hidden) {
        // eslint-disable-next-line promise/catch-or-return
        this.fetchDashboardData().finally(schedule);
      } else {
        // Inactive tab? skip fetch and schedule again
        schedule();
      }
    },
    stopAutoRefresh() {
      clearTimeout(this.timeoutId);
      this.timeoutId = null;
    },

    setRefreshInterval(option) {
      this.refreshInterval = option;
    },
    removeRefreshInterval() {
      this.refreshInterval = null;
    },
    isChecked(option) {
      if (this.refreshInterval) {
        return option.interval === this.refreshInterval.interval;
      }
      return false;
    },
  },

  refreshIntervals: [
    {
      interval: 5 * 1000,
      shortLabel: __('5s'),
      label: __('5 seconds'),
    },
    {
      interval: 10 * 1000,
      shortLabel: __('10s'),
      label: __('10 seconds'),
    },
    {
      interval: 30 * 1000,
      shortLabel: __('30s'),
      label: __('30 seconds'),
    },
    {
      interval: 5 * 60 * 1000,
      shortLabel: __('5m'),
      label: __('5 minutes'),
    },
    {
      interval: 30 * 60 * 1000,
      shortLabel: __('30m'),
      label: __('30 minutes'),
    },
    {
      interval: 60 * 60 * 1000,
      shortLabel: __('1h'),
      label: __('1 hour'),
    },
    {
      interval: 2 * 60 * 60 * 1000,
      shortLabel: __('2h'),
      label: __('2 hours'),
    },
  ],
};
</script>

<template>
  <gl-button-group>
    <gl-button
      ref="refreshBtn"
      v-gl-tooltip
      class="flex-grow-1"
      variant="default"
      :title="s__('Metrics|Refresh dashboard')"
      icon="retry"
      @click="refresh"
    />
    <gl-new-dropdown :text="dropdownText">
      <gl-new-dropdown-item
        :is-check-item="true"
        :is-checked="refreshInterval === null"
        @click="removeRefreshInterval()"
        >{{ __('Off') }}</gl-new-dropdown-item
      >
      <gl-new-dropdown-divider />
      <gl-new-dropdown-item
        v-for="(option, i) in $options.refreshIntervals"
        :key="i"
        :is-check-item="true"
        :is-checked="isChecked(option)"
        @click="setRefreshInterval(option)"
        >{{ option.label }}</gl-new-dropdown-item
      >
    </gl-new-dropdown>
  </gl-button-group>
</template>
