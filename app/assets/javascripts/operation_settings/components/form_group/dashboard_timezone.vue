<script>
import { s__ } from '~/locale';
import { mapState, mapActions } from 'vuex';
import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { dashboardTimezoneOptions } from '../../constants';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
  },
  computed: {
    ...mapState(['dashboardTimezone']),
    userDashboardTimezoneSetting: {
      get() {
        return this.dashboardTimezone.setting;
      },
      set(setting) {
        this.setDashboardTimezoneSetting(setting);
      },
    },
    options() {
      return [
        {
          value: dashboardTimezoneOptions.LOCAL,
          text: s__("MetricsSettings|User's local timezone"),
        },
        {
          value: dashboardTimezoneOptions.UTC,
          text: s__('MetricsSettings|UTC (Coordinated Universal Time)'),
        },
      ];
    },
  },
  methods: {
    ...mapActions(['setDashboardTimezoneSetting']),
  },
};
</script>

<template>
  <gl-form-group
    :label="s__('MetricsSettings|Dashboard timezone')"
    label-for="dashboard-timezeon-setting"
  >
    <template #description>
      {{
        s__(
          "MetricsSettings|Choose whether to display dashboard metrics in UTC or the user's local timezone.",
        )
      }}
    </template>

    <gl-form-select v-model="userDashboardTimezoneSetting" :options="options" />
  </gl-form-group>
</template>
