<script>
import { GlBadge, GlLoadingIcon } from '@gitlab/ui';
import Api from 'ee/api';
import LoadingButton from '~/vue_shared/components/loading_button.vue';
import axios from '~/lib/utils/axios_utils';
import { redirectTo } from '~/lib/utils/url_utility';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import VulnerabilityStateDropdown from './vulnerability_state_dropdown.vue';
import StatusText from './status_text.vue';
import { VULNERABILITY_STATES } from '../constants';

export default {
  name: 'VulnerabilityManagementApp',
  components: {
    GlBadge,
    VulnerabilityStateDropdown,
    LoadingButton,
    StatusText,
    GlLoadingIcon,
  },

  props: {
    initialVulnerability: {
      type: Object,
      required: true,
    },
    finding: {
      type: Object,
      required: true,
    },
    pipeline: {
      type: Object,
      default: () => ({}),
    },
    pipelineUrl: {
      type: String,
      default: '',
    },
    createIssueUrl: {
      type: String,
      required: true,
    },
  },

  data() {
    return {
      isLoadingVulnerability: false,
      isCreatingIssue: false,
      vulnerability: this.initialVulnerability,
      state: this.initialVulnerability.state,
    };
  },

  computed: {
    variant() {
      // Get the badge variant based on the vulnerability state, defaulting to 'warning'.
      const variant = VULNERABILITY_STATES[this.state]?.variant || 'warning';
      return variant;
    },
  },

  methods: {
    changeVulnerabilityState(newState) {
      this.isLoadingVulnerability = true;

      Api.changeVulnerabilityState(this.vulnerability.id, newState)
        .then(({ data }) => {
          this.vulnerability = data;
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
            project_fingerprint: this.finding.project_fingerprint,
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
  <div class="d-flex align-items-center border-bottom py-2">
    <gl-badge ref="badge" class="text-capitalize" :variant="variant">
      <gl-loading-icon v-if="isLoadingVulnerability" />
      <template v-else>{{ vulnerability.state }}</template>
    </gl-badge>

    <status-text
      class="mx-2"
      :vulnerability="vulnerability"
      :pipeline="pipeline"
      :pipeline-url="pipelineUrl"
      :is-loading="isLoadingVulnerability"
    />

    <label class="mb-0 ml-auto mr-2">{{ __('Status') }}</label>

    <gl-loading-icon v-if="isLoadingVulnerability" />
    <vulnerability-state-dropdown
      v-else
      ref="dropdown"
      :initial-state="state"
      @change="changeVulnerabilityState"
    />

    <loading-button
      ref="create-issue-btn"
      class="align-items-center d-inline-flex align-self-stretch ml-2"
      :loading="isCreatingIssue"
      :label="s__('VulnerabilityManagement|Create issue')"
      container-class="btn btn-success btn-inverted"
      @click="createIssue"
    />
  </div>
</template>
