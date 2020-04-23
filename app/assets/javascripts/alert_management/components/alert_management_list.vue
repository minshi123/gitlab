<script>
import { mapState } from 'vuex';
import { GlEmptyState, GlButton, GlLoadingIcon, GlTable, GlAlert } from '@gitlab/ui';
import { __ } from '~/locale';
import getAlerts from '../graphql/queries/getAlerts.query.graphql';

const tdClass = 'table-col d-flex';

export default {
  i18n: {
    noAlertsMsg:  __('No alerts available to display. If you think you\'re seeing this message in error, refresh the page.'),
    errorMsg: __('No alerts received from the configured endpoint. Confirm your endpoint\'s configuration details to ensure alerts appear.'),
  },
  fields: [
    {
      key: 'severity',
      label: __('Severity'),
      tdClass,
    },
    {
      key: 'start_time',
      label: __('Start Time'),
      tdClass,
    },
    {
      key: 'end_time',
      label: __('End Time'),
      tdClass,
    },
    {
      key: 'alert',
      label: __('Alert'),
      thClass: 'w-30p',
      tdClass,
    },
    {
      key: 'events',
      label: __('Events'),
      tdClass,
    },
    {
      key: 'status',
      label: __('Status'),
      tdClass,
    },
  ],
  components: {
    GlEmptyState,
    GlButton,
    GlLoadingIcon,
    GlTable,
    GlAlert,
  },
  props: {
    indexPath: {
      type: String,
      required: true,
    },
    // TODO: Handle alertManagementEnabled depending on resolution - https://gitlab.com/gitlab-org/gitlab/-/merge_requests/30024.
    alertManagementEnabled: {
      type: Boolean,
      required: false,
      default: true,
    },
    enableAlertManagementPath: {
      type: String,
      required: true,
    },
    emptyAlertSvgPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
      alerts: {
        query: getAlerts,
        variables() {
          return {
            projectPath: this.indexPath,
          }
        },
        error() {
          this.errored = true;
        }
      },
  },
  data() {
    return {
      errored: false,
      isAlertDismissed: false,
      isErrorAlertDismissed: false,
    };
  },
  computed: {
    // ...mapState('list', ['alerts', 'loading']),
    showNoAlertsMsg() {
      return this.alerts && !this.alerts.length && !this.isAlertDismissed;
    },
    showErrorMsg(){
     // return this.errored && !this.isErrorAlertDismissed;
      return false;
    },
    loading() {
      // return this.$apollo.queries.alerts.loading;
      return true;
    },
  },
};
</script>

<template>
  <div>
    <div v-if="alertManagementEnabled" class="alert-management-list">
      <gl-alert v-if="showNoAlertsMsg" @dismiss="isAlertDismissed = true">
        {{ $options.i18n.noAlertsMsg}}
      </gl-alert>
      <gl-alert v-if="showErrorMsg" @dismiss="isErrorAlertDismissed = true" variant="danger">
        {{ $options.i18n.errorMsg}}
      </gl-alert>

      <gl-table
        class="mt-3"
        :items="alerts"
        :fields="$options.fields"
        :show-empty="true"
        :busy="loading"
        fixed
        stacked="sm"
        tbody-tr-class="table-row mb-4"
      >
        <template #empty>
          {{ __('No alerts to display.') }}
        </template>
        <template #table-busy>
          <gl-loading-icon size="lg" color="dark" class="mt-3"/>
        </template>
      </gl-table>
    </div>
    <template v-else>
      <gl-empty-state :title="__('Surface alerts in GitLab')" :svg-path="emptyAlertSvgPath">
        <template #description>
          <div class="d-block">
            <span>{{
              __(
                'Display alerts from all your monitoring tools directly within GitLab. Streamline the investigation of your alerts and the escalation of alerts to incidents.',
              )
            }}</span>
            <a href="/help/user/project/operations/alert_management.html">
              {{ __('More information') }}
            </a>
          </div>
          <div class="d-block center pt-4">
            <gl-button category="primary" variant="success" :href="enableAlertManagementPath">
              {{ __('Authorize external service') }}
            </gl-button>
          </div>
        </template>
      </gl-empty-state>
    </template>
  </div>
</template>
