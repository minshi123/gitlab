<script>
import { GlBadge, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import Api from 'ee/api';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import axios from '~/lib/utils/axios_utils';
import { redirectTo } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import ResolutionAlert from './resolution_alert.vue';
import VulnerabilityStateDropdown from './vulnerability_state_dropdown.vue';
import { VULNERABILITY_STATES } from '../constants';

export default {
  name: 'VulnerabilityManagementApp',
  components: {
    GlBadge,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
    LoadingButton,
    ResolutionAlert,
    TimeAgoTooltip,
    VulnerabilityStateDropdown,
  },

  props: {
    vulnerability: {
      type: Object,
      required: true,
    },
    pipeline: {
      type: Object,
      required: false,
      default: undefined,
    },
    createIssueUrl: {
      type: String,
      required: true,
    },
    projectFingerprint: {
      type: String,
      required: true,
    },
  },

  data() {
    return {
      isLoadingVulnerability: false,
      isCreatingIssue: false,
      state: this.vulnerability.state,
    };
  },

  computed: {
    variant() {
      // Get the badge variant based on the vulnerability state, defaulting to 'warning'.
      return VULNERABILITY_STATES[this.state]?.variant || 'warning';
    },
    showResolutionAlert() {
      return this.vulnerability.resolved_on_default_branch && this.state !== 'resolved';
    },
  },

  methods: {
    onVulnerabilityStateChange(newState) {
      this.isLoadingVulnerability = true;

      Api.changeVulnerabilityState(this.vulnerability.id, newState)
        .then(({ data }) => {
          this.state = data.state;
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong, could not update vulnerability state.',
            ),
          );
        })
        .finally(() => {
          this.isLoadingVulnerability = false;
        });
    },
    createIssue() {
      this.isCreatingIssue = true;
      axios
        .post(this.createIssueUrl, {
          vulnerability_feedback: {
            feedback_type: 'issue',
            category: this.vulnerability.report_type,
            project_fingerprint: this.projectFingerprint,
            vulnerability_data: { ...this.vulnerability, category: this.vulnerability.report_type },
          },
        })
        .then(({ data: { issue_url } }) => {
          redirectTo(issue_url);
        })
        .catch(() => {
          this.isCreatingIssue = false;
          createFlash(
            s__('VulnerabilityManagement|Something went wrong, could not create an issue.'),
          );
        });
    },
  },
};
</script>

<template>
  <div>
    <resolution-alert v-if="showResolutionAlert" />

    <div class="d-flex align-items-center border-bottom pt-2 pb-2">
      <gl-loading-icon v-if="isLoadingVulnerability" />
      <gl-badge v-else ref="badge" class="text-capitalize" :variant="variant">{{ state }}</gl-badge>

      <span v-if="pipeline" class="mx-2">
        <gl-sprintf :message="__('Detected %{timeago} in pipeline %{pipelineLink}')">
          <template #timeago>
            <time-ago-tooltip :time="pipeline.created_at" />
          </template>
          <template v-if="pipeline.id" #pipelineLink>
            <gl-link :href="pipeline.url" target="_blank">{{ pipeline.id }}</gl-link>
          </template>
        </gl-sprintf>
      </span>

      <time-ago-tooltip v-else class="ml-2" :time="vulnerability.created_at" />

      <label class="mb-0 ml-auto mr-2">{{ __('Status') }}</label>
      <gl-loading-icon v-if="isLoadingVulnerability" />
      <vulnerability-state-dropdown
        v-else
        :initial-state="state"
        @change="onVulnerabilityStateChange"
      />
      <loading-button
        ref="create-issue-btn"
        class="align-items-center d-inline-flex ml-2"
        :loading="isCreatingIssue"
        :label="s__('VulnerabilityManagement|Create issue')"
        container-class="btn btn-success btn-inverted"
        @click="createIssue"
      />
    </div>
  </div>
</template>
