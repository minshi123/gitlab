<script>
import {
  GlLink,
  GlSprintf,
  GlAvatarLabeled,
  GlAvatarLink,
  GlSkeletonLoading,
  GlLoadingIcon,
} from '@gitlab/ui';
import Api from 'ee/api';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  name: 'VulnerabilityManagementApp',
  components: {
    GlLink,
    GlSprintf,
    GlAvatarLabeled,
    GlAvatarLink,
    TimeAgoTooltip,
    GlSkeletonLoading,
    GlLoadingIcon,
  },

  props: {
    vulnerability: {
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
    isLoading: Boolean,
  },

  data() {
    return {
      isLoadingUser: false,
      user: undefined,
    };
  },

  computed: {
    isDetectedByPipeline() {
      return this.vulnerability.state === 'detected' && Boolean(this.pipeline);
    },

    time() {
      // If the vulnerability was detected by a pipeline, use the pipeline created at time.
      if (this.isDetectedByPipeline) {
        return this.pipeline.created_at;
      } else if (this.vulnerability.state === 'detected') {
        return this.vulnerability.created_at;
      }
      // This special condition can be removed once this MR is merged:
      // https://gitlab.com/gitlab-org/gitlab/-/merge_requests/25609
      else if (this.vulnerability.state === 'dismissed') {
        return this.vulnerability.closed_at;
      }

      return this.vulnerability[`${this.vulnerability.state}_at`];
    },

    statusText() {
      const { state } = this.vulnerability;

      if (this.isDetectedByPipeline) {
        return s__('VulnerabilityManagement|Detected %{timeago} in pipeline %{pipelineLink}');
      } else if (state === 'confirmed') {
        return s__('VulnerabilityManagement|Confirmed %{timeago} by %{user}');
      } else if (state === 'dismissed') {
        return s__('VulnerabilityManagement|Dismissed %{timeago} by %{user}');
      } else if (state === 'resolved') {
        return s__('VulnerabilityManagement|Resolved %{timeago} by %{user}');
      }

      return s__('VulnerabilityManagement|Detected %{timeago}');
    },
  },

  watch: {
    vulnerability: {
      immediate: true,
      handler: function getUser(vulnerability) {
        const id =
          vulnerability.state === 'dismissed'
            ? this.vulnerability.closed_by_id
            : this.vulnerability[`${vulnerability.state}_by_id`];

        // Don't try to get the user if we don't have an ID.
        if (id === undefined) return;

        this.isLoadingUser = true;

        Api.user(id)
          .then(({ data }) => {
            this.user = data;
          })
          .catch(() => {
            createFlash(s__('VulnerabilityManagement|Something went wrong, could not get user.'));
          })
          .finally(() => {
            this.isLoadingUser = false;
          });
      },
    },
  },
};
</script>

<template>
  <span>
    <gl-skeleton-loading v-if="isLoading" :lines="2" class="h-auto" />
    <gl-sprintf v-else :message="statusText">
      <template #span="{ content }">
        <span class="align-middle">{{ content }}</span>
      </template>
      <template #timeago>
        <time-ago-tooltip :time="time" />
      </template>
      <template #user>
        <gl-loading-icon v-if="isLoadingUser" class="d-inline ml-1" />
        <gl-avatar-link v-else-if="user" target="blank" :href="user.user_path" class="align-middle">
          <gl-avatar-labeled
            class="vulnerability-status-avatar"
            :src="user.avatar_url"
            :label="user.name"
            :size="24"
          />
        </gl-avatar-link>
      </template>
      <template v-if="pipelineUrl" #pipelineLink>
        <gl-link :href="pipelineUrl" target="_blank">{{ pipeline.id }}</gl-link>
      </template>
    </gl-sprintf>
  </span>
</template>

<style>
.vulnerability-status-avatar .gl-avatar-labeled-labels {
  margin-left: 0.3rem;
}
</style>
