<script>
import { GlEmptyState, GlIcon, GlLabel, GlLink, GlSkeletonLoader } from '@gitlab/ui';

export default {
  name: 'ComingSoon',
  components: {
    GlEmptyState,
    GlIcon,
    GlLabel,
    GlLink,
    GlSkeletonLoader,
  },
  props: {
    issues: {
      type: Array,
      required: true,
      default: () => [],
    },
    isLoading: {
      type: Boolean,
      default: true,
      required: true,
    },
    illustration: {
      type: String,
      required: true,
    },
  },
  loadingRows: 5,
};
</script>

<template>
  <div>
    <div v-if="isLoading" class="d-flex flex-column">
      <gl-skeleton-loader
        v-for="index in $options.loadingRows"
        :key="index"
        :width="1000"
        :height="80"
        preserve-aspect-ratio="xMinYMax meet"
      >
        <rect width="700" height="10" x="0" y="16" rx="4" />
        <rect width="60" height="10" x="0" y="45" rx="4" />
        <rect width="60" height="10" x="70" y="45" rx="4" />
      </gl-skeleton-loader>
    </div>

    <template v-else-if="issues.length > 0">
      <div v-for="issue in issues" :key="issue.id" ref="issue-row" class="gl-responsive-table-row">
        <div
          class="table-section section-100 d-flex flex-column align-items-start flex-wrap text-truncate"
        >
          <gl-link :href="issue.web_url" class="text-dark font-weight-bold">
            {{ issue.title }}
          </gl-link>

          <div class="d-flex text-secondary mt-3">
            <gl-icon name="issues" class="append-right-4" />
            <gl-link :href="issue.web_url" class="text-secondary append-right-default"
              >#{{ issue.iid }}</gl-link
            >

            <div v-if="issue.milestone" class="d-flex align-items-center append-right-default">
              <gl-icon name="clock" class="append-right-4" />
              <span>{{ issue.milestone.title }}</span>
            </div>

            <gl-label
              v-if="issue.workflow"
              ref="workflow-label"
              class="append-right-8"
              size="sm"
              :background-color="issue.workflow.color"
              :title="issue.workflow.name"
              scoped
            />

            <gl-label
              v-if="issue.isAcceptingContributions"
              ref="contributions-label"
              size="sm"
              :background-color="issue.isAcceptingContributions.color"
              :title="issue.isAcceptingContributions.name"
            />
          </div>
        </div>
      </div>
    </template>

    <template v-else>
      <gl-empty-state
        :title="s__('PackageRegistry|No Coming Soon Issues')"
        :svg-path="illustration"
      >
        <template #description>
          <p>{{ s__('PackageRegistry|There are no upcoming issues to display.') }}</p>
        </template>
      </gl-empty-state>
    </template>
  </div>
</template>
