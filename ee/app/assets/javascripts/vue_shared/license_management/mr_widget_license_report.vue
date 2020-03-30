<script>
import { mapState, mapGetters, mapActions } from 'vuex';
import { GlLink } from '@gitlab/ui';
import reportsMixin from 'ee/vue_shared/security_reports/mixins/reports_mixin';
import ReportItem from '~/reports/components/report_item.vue';
import SmartVirtualList from '~/vue_shared/components/smart_virtual_list.vue';
import SetLicenseApprovalModal from 'ee/vue_shared/license_management/components/set_approval_status_modal.vue';
import { componentNames } from 'ee/reports/components/issue_body';
import Icon from '~/vue_shared/components/icon.vue';
import ReportSection from '~/reports/components/report_section.vue';

import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_management/store/constants';
import { REPORT_HEADERS } from 'ee/vue_shared/license_management/constants';
import { STATUS_FAILED, STATUS_NEUTRAL, STATUS_SUCCESS } from '~/reports/constants';

import createStore from './store';

const store = createStore();

export default {
  name: 'MrWidgetLicenses',
  componentNames,
  store,
  components: {
    GlLink,
    ReportItem,
    ReportSection,
    SetLicenseApprovalModal,
    SmartVirtualList,
    Icon,
  },
  mixins: [reportsMixin],
  statusHeaders: {
    [STATUS_FAILED]: REPORT_HEADERS[STATUS_FAILED],
    [STATUS_NEUTRAL]: REPORT_HEADERS[STATUS_NEUTRAL],
    [STATUS_SUCCESS]: REPORT_HEADERS[STATUS_SUCCESS],
  },
  props: {
    fullReportPath: {
      type: String,
      required: false,
      default: null,
    },
    licenseManagementSettingsPath: {
      type: String,
      required: false,
      default: null,
    },
    apiUrl: {
      type: String,
      required: true,
    },
    licensesApiPath: {
      type: String,
      required: false,
      default: '',
    },
    canManageLicenses: {
      type: Boolean,
      required: true,
    },
    reportSectionClass: {
      type: String,
      required: false,
      default: '',
    },
    alwaysOpen: {
      type: Boolean,
      required: false,
      default: false,
    },
    securityApprovalsHelpPagePath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState(LICENSE_MANAGEMENT, ['loadLicenseReportError']),
    ...mapGetters(LICENSE_MANAGEMENT, [
      'licenseReport',
      'licenseReportGroupedByStatus',
      'isLoading',
      'licenseSummaryText',
      'reportContainsBlacklistedLicense',
    ]),
    hasLicenseReportIssues() {
      const { licenseReport } = this;
      return licenseReport && licenseReport.length > 0;
    },
    licenseReportStatus() {
      return this.checkReportStatus(this.isLoading, this.loadLicenseReportError);
    },
    showActionButtons() {
      return this.licenseManagementSettingsPath !== null || this.fullReportPath !== null;
    },
  },
  watch: {
    licenseReport() {
      this.$emit('updateBadgeCount', this.licenseReport.length);
    },
  },
  mounted() {
    const { apiUrl, canManageLicenses, licensesApiPath } = this;

    this.setAPISettings({
      apiUrlManageLicenses: apiUrl,
      canManageLicenses,
      licensesApiPath,
    });

    this.fetchParsedLicenseReport();
  },
  methods: {
    ...mapActions(LICENSE_MANAGEMENT, ['setAPISettings', 'fetchParsedLicenseReport']),
  },
};
</script>
<template>
  <div>
    <set-license-approval-modal />
    <report-section
      :status="licenseReportStatus"
      :loading-text="licenseSummaryText"
      :error-text="licenseSummaryText"
      :neutral-issues="licenseReport"
      :has-issues="hasLicenseReportIssues"
      :component="$options.componentNames.LicenseIssueBody"
      :class="reportSectionClass"
      :always-open="alwaysOpen"
      class="license-report-widget mr-report"
      data-qa-selector="license_report_widget"
    >
      <template #body>
        <!-- smart virtual list of licenses: ul-->
        <smart-virtual-list
          :size="32"
          :length="licenseReport.length"
          :remain="20"
          class="report-block-container"
          wtag="ul"
          wclass="report-block-list"
        >
          <li>
            <h2>{{ $options.statusHeaders.failed.main }}</h2>
            <report-item
              v-for="(issue, index) in licenseReportGroupedByStatus.failed"
              :key="index"
              :issue="issue"
              :status="issue.status"
              :component="$options.componentNames.LicenseIssueBody"
              :show-report-section-status-icon="true"
            />
          </li>
          <li>
            <h2>{{ $options.statusHeaders.neutral.main }}</h2>
            <report-item
              v-for="(issue, index) in licenseReportGroupedByStatus.neutral"
              :key="index"
              :issue="issue"
              :status="issue.status"
              :component="$options.componentNames.LicenseIssueBody"
              :show-report-section-status-icon="true"
            />
          </li>
          <li>
            <h2>{{ $options.statusHeaders.success.main }}</h2>
            <report-item
              v-for="(issue, index) in licenseReportGroupedByStatus.success"
              :key="index"
              :issue="issue"
              :status="issue.status"
              :component="$options.componentNames.LicenseIssueBody"
              :show-report-section-status-icon="true"
            />
          </li>
        </smart-virtual-list>
      </template>
      <template #success>
        {{ licenseSummaryText }}
        <gl-link
          v-if="reportContainsBlacklistedLicense && securityApprovalsHelpPagePath"
          :href="securityApprovalsHelpPagePath"
          class="js-security-approval-help-link"
          target="_blank"
        >
          <icon :size="12" name="question" />
        </gl-link>
      </template>
      <div v-if="showActionButtons" slot="actionButtons" class="append-right-default">
        <a
          v-if="licenseManagementSettingsPath"
          :class="{ 'append-right-8': fullReportPath }"
          :href="licenseManagementSettingsPath"
          class="btn btn-default btn-sm js-manage-licenses"
        >
          {{ s__('ciReport|Manage licenses') }}
        </a>
        <a
          v-if="fullReportPath"
          :href="fullReportPath"
          target="_blank"
          class="btn btn-default btn-sm js-full-report"
        >
          {{ s__('ciReport|View full report') }} <icon :size="16" name="external-link" />
        </a>
      </div>
    </report-section>
  </div>
</template>
